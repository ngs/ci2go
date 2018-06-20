//
//  BuildActionsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import Crashlytics
import PusherSwift
import Dwifft

class BuildActionsViewController: UITableViewController {
    var isLoading = false
    var isMutating = false
    var diffCalculator: TableViewDiffCalculator<Int, BuildAction>?
    var reloadTimer: Timer?

    var build: Build? {
        didSet {
            guard let build = build else { return }
            title = "\(build.project.name) #\(build.number)"
            DispatchQueue.main.async { self.refreshData() }
        }
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: BuildActionTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: BuildActionTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBuild()
        connectPusher()
        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard
                let tableView = self?.tableView,
                let indexPaths = tableView.indexPathsForVisibleRows,
                self?.isMutating == false
                else { return }
            tableView.reloadRows(at: indexPaths, with: .none)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        reloadTimer?.invalidate()
        reloadTimer = nil
    }

    // MARK: -

    func loadBuild() {
        guard let build = self.build, !isLoading else {
            return
        }
        isLoading = true
        URLSession.shared.dataTask(endpoint: .get(build: build)) { (build, _, _, err) in
            self.isLoading = false
            self.build = build
            }.resume()
    }

    func refreshData() {
        guard let steps = build?.steps, steps.count > 0 else { return }
        isMutating = true
        let values: [BuildAction] = steps.flatMap { $0.actions }.sorted()
        diffCalculator?.sectionedValues = SectionedValues<Int, BuildAction>([(0, values)])
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isMutating = false
        }
    }

    func connectPusher() {
        guard
            let pusher = Pusher.shared,
            let build = build
            else { return }
        let channels = build.pusherChannelNames.map {
            pusher.subscribe($0)
        }
        let events: [PusherEvent] = [.updateAction, .newAction]
        channels.forEach { channel in
            events.forEach {
                channel.bind($0, { [weak self] _ in
                    self?.loadBuild()
                })
            }
        }
    }

    // MARK: -

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BuildActionTableViewCell.identifier) as? BuildActionTableViewCell
        cell?.buildAction = diffCalculator?.value(atIndexPath: indexPath)
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath), cell.selectionStyle != .none else { return }
        performSegue(withIdentifier: .showBuildLog, sender: cell)
    }
}
