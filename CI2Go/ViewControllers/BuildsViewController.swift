//
//  BuildsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import KeychainAccess
import PusherSwift
import Dwifft
import WatchConnectivity

class BuildsViewController: UITableViewController {
    let apiRequestOperationQueue = OperationQueue()
    var hasMore = false
    var currentOffset = 0
    let limit = 30
    var diffCalculator: TableViewDiffCalculator<Int, Build?>?
    var isMutating = false
    var reloadTimer: Timer?
    var foregroundObserver: NSObjectProtocol?

    var selected: (Project?, Branch?) {
        didSet {
            let (oldProject, oldBranch) = oldValue
            let (project, branch) = selected
            let defaults = UserDefaults.shared
            if let branch = branch {
                defaults.branch = branch
            } else if let project = project {
                defaults.project = project
            } else {
                defaults.project = nil
                defaults.branch = nil
            }
            if oldProject != project || oldBranch != branch {
                builds = []
                apiRequestOperationQueue.cancelAllOperations()
                loadBuilds()
                if let branch = branch {
                    navigationItem.prompt = branch.promptText
                } else if let project = project {
                    navigationItem.prompt = project.promptText
                } else {
                    navigationItem.prompt = nil
                }
                navigationController?.navigationBar.setNeedsLayout()
            }
            DispatchQueue.global().async {
                WCSession.default.transferSelected(project: project, branch: branch)
            }
        }
    }

    var currentUser: User? {
        didSet {
            if currentUser == oldValue { return }
            if let user = currentUser {
                Crashlytics.crashlytics().setUserID(user.login)
                connectPusher()
            } else {
                Pusher.logout()
            }
        }
    }

    var builds: [Build] = [] {
        didSet {
            DispatchQueue.main.async { self.refreshData() }
        }
    }

    var isLoading = false {
        didSet {
            DispatchQueue.main.async { self.refreshData() }
        }
    }

    // MARK: - UIViewController

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let token = Keychain.shared.token, isValidToken(token) else {
            logout()
            return
        }
        loadUser()
        loadBuilds()
        connectPusher()
        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard
                let tableView = self?.tableView,
                let indexPaths = tableView.indexPathsForVisibleRows,
                self?.isMutating == false && indexPaths.count > 0
                else { return }
            tableView.reloadRows(at: indexPaths, with: .none)
        }
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: nil) { [weak self] _ in
                self?.loadUser()
                self?.loadBuilds()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        reloadTimer?.invalidate()
        reloadTimer = nil
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
        foregroundObserver = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: LoadingCell.identifier, bundle: nil),
            forCellReuseIdentifier: LoadingCell.identifier)
        tableView.register(
            UINib(nibName: BuildTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: BuildTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        builds = []
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadBuilds), for: .valueChanged)
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
        let defaults = UserDefaults.shared
        selected = (defaults.project, defaults.branch)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, sender) {
        case let (viewController as BuildActionsViewController, cell as BuildTableViewCell):
            viewController.build = cell.build
        case let (viewController as BuildActionsViewController, build as Build):
            viewController.build = build
        default:
            break
        }
    }

    // MARK: -

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        if let token = Keychain.shared.token, !token.isEmpty && builds.isEmpty {
            loadUser()
            loadBuilds()
        }
    }

    func refreshData() {
        isMutating = true
        var values: [(Int, [Build?])] = [(0, builds)]
        if isLoading {
            values.append((1, [nil]))
        }
        diffCalculator?.sectionedValues = SectionedValues<Int, Build?>(values)
        refreshControl?.endRefreshing()
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isMutating = false
        }
    }

    func loadUser() {
        URLSession.shared.dataTask(endpoint: .me) { [weak self] (user, _, res, err) in
            guard let user = user else {
                Crashlytics.crashlytics().record(error: err ?? APIError.noData)
                if let res = res as? HTTPURLResponse, res.statusCode == 401 {
                    self?.logout()
                }
                return
            }
            self?.currentUser = user
            }.resume()
    }

    func connectPusher() {
        guard
            let user = currentUser,
            let channelName = user.pusherChannelName,
            let pusher = Pusher.shared,
            pusher.connection.connectionState == .disconnected
            else { return }
        let userChannel = pusher.subscribe(channelName)
        userChannel.bind(.call) { _ in self.loadBuilds() }
        pusher.bind { [weak self] (message: Any?) in
            guard
                let message = message as? [String: Any],
                let eventName = message["event"] as? String,
                eventName == "pusher:subscription_error"
                else { return }
            self?.logout()
        }
        pusher.connect()
    }

    func logout(showSettings: Bool = true) {
        Pusher.logout()
        builds = []
        Keychain.shared.token = nil
        if showSettings {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.showSettings()
            })
        }
    }

    func showSettings() {
        if let settingsViewControler = (presentedViewController as? UINavigationController)?
            .viewControllers.first as? SettingsViewController {
            settingsViewControler.refreshData()
            return
        }
        performSegue(withIdentifier: .showSettings, sender: nil)
    }

    @objc func loadBuilds(more: Bool = false) {
        if isLoading {
            return
        }
        isLoading = true
        if !more {
            currentOffset = 0
        }
        let (project, branch) = selected
        apiRequestOperationQueue.addOperation {
            URLSession.shared.dataTask(
                endpoint: .builds(
                    object: branch ?? project,
                    offset: self.currentOffset,
                    limit: self.limit)
            ) { [weak self] (builds, _, _, err) in
                guard let `self` = self else { return }
                let builds = builds ?? []
                let newBuilds: [Build] = self.builds.merged(with: builds).sorted().reversed()
                self.currentOffset = more ? newBuilds.count : builds.count
                self.isLoading = false
                if let err = err {
                    Crashlytics.crashlytics().record(error: err)
                    return
                }
                self.hasMore = builds.count >= self.limit
                self.builds = newBuilds
                }.resume()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BuildTableViewCell.height(for: diffCalculator?.value(atIndexPath: indexPath))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.identifier)!
            cell.accessibilityIdentifier = "activityIndicatorCell"
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BuildTableViewCell.identifier) as? BuildTableViewCell
            else { fatalError() }
        cell.build = diffCalculator?.value(atIndexPath: indexPath)
        cell.accessibilityIdentifier = "buildCell_\(indexPath.row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BuildTableViewCell else { return }
        performSegue(withIdentifier: .showBuildDetail, sender: cell)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastVisible = tableView.indexPathsForVisibleRows?.last,
            lastVisible.row >= currentOffset - 1 && hasMore && !isLoading else { return }
        loadBuilds(more: true)
    }

}
