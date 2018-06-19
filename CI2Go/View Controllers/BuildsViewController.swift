//
//  BuildsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import KeychainAccess
import Crashlytics
import PusherSwift
import Dwifft

class BuildsViewController: UITableViewController {
    var hasMore = false
    var currentOffset = 0
    let limit = 30
    var diffCalculator: TableViewDiffCalculator<Int, Build>?
    var isMutating = false
    var reloadTimer: Timer?
    var foregroundObserver: NSObjectProtocol?

    var currentUser: User? {
        didSet {
            if currentUser == oldValue { return }
            if let _ = currentUser {
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

    var isLoading = false  {
        didSet {
            DispatchQueue.main.async { self.refreshData() }
        }
    }

    lazy var dummyLoadingBuild: Build = {
        let project = Project(vcs: .github, username: "-", name: "-")
        return Build(project: project, number: -1)
    }()

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let token = Keychain.shared.token, isValidToken(token) else {
            showSettings()
            return
        }
        loadUser()
        loadBuilds()
        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard
                let tableView = self?.tableView,
                let indexPaths = tableView.indexPathsForVisibleRows
                else { return }
            tableView.reloadRows(at: indexPaths, with: .none)
        }
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationWillEnterForeground,
            object: nil,
            queue: nil) { [weak self] _ in self?.loadUser() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        reloadTimer?.invalidate()
        reloadTimer = nil
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        builds = []
    }

    func refreshData() {
        isMutating = true
        var values = [(0, builds)]
        if isLoading {
            values.append((1, [dummyLoadingBuild]))
        }
        diffCalculator?.sectionedValues = SectionedValues<Int, Build>(values)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isMutating = false
        }
    }

    func loadUser() {
        URLSession.shared.dataTask(endpoint: .me) { (user, _, err) in
            guard let user = user else {
                Crashlytics.sharedInstance().recordError(err ?? APIError.noData)
                DispatchQueue.main.async { self.showSettings() }
                return
            }
            self.currentUser = user
            }.resume()
    }

    func connectPusher() {
        guard
            let user = currentUser,
            let channelName = user.pusherChannelName,
            let pusher = Pusher.shared,
            pusher.connection.connectionState != .connected
            else { return }

        let userChannel = pusher.subscribe(channelName)
        userChannel.bind(.call) { _ in self.loadBuilds() }
        pusher.connect()
    }

    func showSettings() {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
    }

    func loadBuilds(more: Bool = false) {
        if isLoading {
            return
        }
        isLoading = true
        if !more {
            currentOffset = 0
        }
        let endpoint: Endpoint<[Build]>
        if let branch = UserDefaults.shared.branch {
            endpoint = .builds(branch: branch, offset: currentOffset, limit: limit)
        } else if let project = UserDefaults.shared.project {
            endpoint = .builds(project: project, offset: currentOffset, limit: limit)
        } else {
            endpoint = .recent(offset: currentOffset, limit: limit)
        }
        URLSession.shared.dataTask(endpoint: endpoint) { [weak self] (builds, _, err) in
            guard let `self` = self else { return }
            let builds = builds ?? []
            let newBuilds: [Build] = self.builds.merged(with: builds).sorted().reversed()
            self.currentOffset = more ? newBuilds.count : builds.count
            self.isLoading = false
            if let err = err {
                Crashlytics.sharedInstance().recordError(err)
                return
            }
            self.hasMore = builds.count >= self.limit
            self.builds = newBuilds
            }.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell")!
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! BuildTableViewCell
        cell.build = diffCalculator?.value(atIndexPath: indexPath)
        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastVisible = tableView.indexPathsForVisibleRows?.last,
            lastVisible.row >= currentOffset - 1 && hasMore && !isLoading else { return }
        loadBuilds(more: true)
    }

}
