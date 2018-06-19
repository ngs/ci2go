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

class BuildsViewController: UITableViewController {
    var currentUser: User?
    var userChannel: PusherChannel?
    var builds = [Build]()
    var hasMore = false
    var isLoading = false
    var currentOffset = 0
    let limit = 30

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
        tableView.reloadData()
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
            let changes = self.builds.merge(elements: builds)
            DispatchQueue.main.async {
                guard let tableView = self.tableView else { return }
                tableView.performBatchUpdates({
                    changes.forEach { change in
                        print(change)
                        switch change {
                        case let .insertRows(indexPaths):
                            tableView.insertRows(at: indexPaths, with: .automatic)
                        case let .updateRows(indexPaths):
                            tableView.reloadRows(at: indexPaths, with: .automatic)
                            return
                        case let .insertSections(sections):
                            tableView.insertSections(sections, with: .automatic)
                        }
                    }
                }, completion: nil)
            }
            }.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return builds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! BuildTableViewCell
        cell.build = builds[indexPath.row]
        return cell
    }


}
