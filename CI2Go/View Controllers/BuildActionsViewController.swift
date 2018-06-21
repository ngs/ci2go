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
    var isNavigatingToNext = false
    var diffCalculator: TableViewDiffCalculator<String, RowItem>?
    var reloadTimer: Timer?
    var pusherChannels: [PusherChannel] = []

    var build: Build? {
        didSet {
            guard let build = build else { return }
            title = "\(build.project.name) #\(build.number)"
            DispatchQueue.main.async {
                self.refreshData(scroll: oldValue?.steps.count != build.steps.count)
            }
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
            let selectedIndexPath = tableView.indexPathForSelectedRow
            tableView.reloadRows(at: indexPaths, with: .none)
            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        reloadTimer?.invalidate()
        reloadTimer = nil
        if let pusher = Pusher.shared, !isNavigatingToNext {
            pusherChannels.forEach {
                pusher.unsubscribe($0.name)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let nvc = segue.destination as? UINavigationController,
            let build = build
            else { return }

        if
            let displayModeButtomItem = splitViewController?.displayModeButtonItem,
            let navigationItem = nvc.topViewController?.navigationItem {
            navigationItem.leftBarButtonItem = displayModeButtomItem
            navigationItem.leftItemsSupplementBackButton = true
        }

        switch (nvc.topViewController, sender) {
        case let (vc as BuildLogViewController, cell as BuildActionTableViewCell):
            guard let action = cell.buildAction else { return }
            vc.pusherChannel = pusherChannels.first(where: { c in
                c.name == "\(build.pusherChannelNamePrefix)@\(action.index)"
            })
            vc.buildAction = action
            break
        case let (vc as TextViewController, _):
            // vc.text = build.conf
            vc.text = build.configuration
            vc.title = build.configurationName
            break
        default:
            break
        }
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

    func refreshData(scroll: Bool = false) {
        guard let steps = build?.steps, steps.count > 0 else { return }
        isMutating = true
        let animateScroll: Bool
        if let (_, items) = diffCalculator?.sectionedValues.sectionsAndValues.first, !items.isEmpty {
            animateScroll = true
        } else {
            animateScroll = false
        }
        let configRow = RowItem(isConfiguration: true)
        let actionRows = steps.flatMap { $0.actions }.sorted().map { RowItem(action: $0) }
        let artifactsRow = RowItem(isArtifacts: true)
        var values: [(String, [RowItem])] = [
            ("Configuration", [configRow]),
            ("Actions", actionRows)
        ]
        if let build = build, build.hasArtifacts, !build.status.isLive {
            values.append(("Artifacts", [artifactsRow]))
        }
        diffCalculator?.sectionedValues = SectionedValues<String, RowItem>(values)

        if scroll {
            scrollToBottom(animated: animateScroll)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isMutating = false
        }
    }

    func connectPusher() {
        guard
            let pusher = Pusher.shared,
            let build = build
            else { return }
        let events: [PusherEvent] = [.updateAction, .newAction]
        pusherChannels = build.pusherChannelNames.map {
            pusher.subscribe($0)
        }
        pusherChannels.forEach { channel in
            events.forEach {
                channel.bind($0, { [weak self] _ in
                    self?.loadBuild()
                })
            }
        }
    }

    func scrollToBottom(animated: Bool = false) {
        let section = numberOfSections(in: tableView) - 1
        let row = tableView(tableView, numberOfRowsInSection: section) - 1
        let diff = tableView.bounds.height + tableView.contentOffset.y - tableView.contentSize.height
        if section >= 0 && row >= 0 && diff < tableView.rowHeight {
            tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: animated)
        }
    }

    func retryBuild() {
        // TODO
    }

    func cancelBuild() {
        // TODO
    }

    @IBAction func openActionSheet(_ sender: Any) {
        let av = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let url = build?.compareURL {
            av.addAction(UIAlertAction(title: "Open diffs in browser", style: .default, handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }
        av.addAction(UIAlertAction(title: "Retry build", style: .default, handler: { _ in
            self.retryBuild()
        }))
        if let build = build, build.status == .running {
            av.addAction(UIAlertAction(title: "Cancel build", style: .default, handler: { _ in
                self.cancelBuild()
            }))
        }
        av.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(av, animated: true, completion: nil)
    }

    // MARK: -

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = diffCalculator?.value(atIndexPath: indexPath) else { fatalError() }
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier)!
        if let cell = cell as? BuildActionTableViewCell {
            cell.buildAction = item.action
        }
        if item.isConfiguration {
            cell.textLabel?.text = build?.configurationName
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return diffCalculator?.value(forSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UINib(nibName: SectionHeaderView.identifier, bundle: nil).instantiate(withOwner: nil, options: nil).first as! SectionHeaderView
        v.text = self.tableView(tableView, titleForHeaderInSection: section)
        return v
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath),
            let item = diffCalculator?.value(atIndexPath: indexPath),
            cell.selectionStyle != .none else { return }
        isNavigatingToNext = true
        performSegue(withIdentifier: item.segueIdentifier, sender: cell)
    }
}

extension BuildActionsViewController {
    struct RowItem: Equatable, Comparable {
        let action: BuildAction?
        let isConfiguration: Bool
        let isArtifacts: Bool

        init(action: BuildAction? = nil, isConfiguration: Bool = false, isArtifacts: Bool = false) {
            self.action = action
            self.isConfiguration = isConfiguration
            self.isArtifacts = isArtifacts
        }

        static func ==(_ lhs: RowItem, _ rhs: RowItem) -> Bool {
            if let la = lhs.action, let ra = rhs.action {
                return la == ra
            }
            return lhs.isConfiguration == rhs.isConfiguration && lhs.isArtifacts == rhs.isArtifacts
        }

        static func < (lhs: RowItem, rhs: RowItem) -> Bool {
            if let la = lhs.action, let ra = rhs.action {
                return la < ra
            }
            if lhs.isConfiguration && !rhs.isConfiguration {

            }
            return lhs.isConfiguration == rhs.isConfiguration && lhs.isArtifacts == rhs.isArtifacts
        }

        var cellIdentifier: String {
            if isConfiguration {
                return "ConfigurationCell"
            }
            if isArtifacts {
                return "ArtifactsCell"
            }
            return BuildActionTableViewCell.identifier
        }

        var segueIdentifier: SegueIdentifier {
            if isConfiguration {
                return .showBuildConfig
            }
            if isArtifacts {
                return .showBuildConfig
            }
            return .showBuildLog
        }
    }
}
