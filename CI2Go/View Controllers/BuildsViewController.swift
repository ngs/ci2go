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
    var currentUser: User?
    var userChannel: PusherChannel?
    var hasMore = false
    var isLoading = false
    var currentOffset = 0
    let limit = 30
    var diffCalculator: TableViewDiffCalculator<Int, Build>?

    var builds: [Build] = [] {
        didSet {
            DispatchQueue.main.async {
                self.diffCalculator?.sectionedValues = SectionedValues<Int, Build>([(0, self.builds)])
            }
        }
    }

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let token = Keychain.shared.token, isValidToken(token) else {
            showSettings()
            return
        }
        connectPusher()
        loadBuilds()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        builds = []
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
            userChannel == nil
            else { return }

        userChannel = pusher.subscribe(channelName)
        userChannel?.bind(.call) { _ in
            self.loadBuilds()
        }
        pusher.connect()
    }

    func showSettings() {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
    }

    func loadBuilds(more: Bool = false) {
        if isLoading {
            return
        }
        if more {
            currentOffset += limit
        } else {
            currentOffset = 0
        }
        let endpoint: Endpoint<[Build]>
        if let branch = UserDefaults.shared.branch {
            endpoint = .builds(branch: branch)
        } else if let project = UserDefaults.shared.project {
            endpoint = .builds(project: project)
        } else {
            endpoint = .recent
        }
        URLSession.shared.dataTask(endpoint: endpoint) { [weak self] (builds, _, err) in
            guard let `self` = self else { return }
            self.isLoading = false
            guard let builds = builds else {
                Crashlytics.sharedInstance().recordError(err ?? APIError.noData)
                return
            }
            self.hasMore = builds.count >= self.limit
            self.builds = builds.reduce(into: self.builds) { (result, element) in
                if let i = result.index(of: element) {
                    result[i] = element
                    return
                }
                result.append(element)
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! BuildTableViewCell
        cell.build = diffCalculator?.value(atIndexPath: indexPath)
        return cell
    }


}
