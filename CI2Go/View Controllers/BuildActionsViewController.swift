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
import MBProgressHUD

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
            DispatchQueue.main.async {
                self.title = "\(build.project.name) #\(build.number)"
                self.refreshData(scroll: oldValue?.steps.count != build.steps.count)
            }
        }
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: BuildActionTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: BuildActionTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNavigatingToNext = false
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
        guard let build = build else { return }
        isNavigatingToNext = true
        let viewController = (segue.destination as? UINavigationController)?.topViewController ?? segue.destination

        if
            (segue.destination as? UINavigationController) != nil,
            let displayModeButtomItem = splitViewController?.displayModeButtonItem {
            viewController.navigationItem.leftBarButtonItem = displayModeButtomItem
            viewController.navigationItem.leftItemsSupplementBackButton = true
        }

        switch (viewController, sender) {
        case let (viewController as BuildLogViewController, cell as BuildActionTableViewCell):
            guard let action = cell.buildAction else { return }
            viewController.pusherChannel = pusherChannels.first(where: { channel in
                channel.name == "\(build.pusherChannelNamePrefix)@\(action.index)"
            })
            viewController.buildAction = action
        case let (viewController as TextViewController, _):
            viewController.text = build.configuration
            viewController.title = build.configurationName
        case let (viewController as BuildArtifactsViewController, _):
            viewController.build = build
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
        URLSession.shared.dataTask(endpoint: .get(build: build)) { [weak self] (build, _, _, _) in
            self?.isLoading = false
            self?.build = build
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
        if let build = build, build.isSSHAvailable {
            let sshRows = build.sshURLs.enumerated().map { (index, url) in
                return RowItem(sshInfo: SSHInfo(index: index, url: url))
            }
            values.append(("SSH", sshRows))
        }
        diffCalculator?.sectionedValues = SectionedValues<String, RowItem>(values)

        if scroll {
            scrollToBottom(animated: animateScroll)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isMutating = false
        }
    }

    func connectPusher() { // TODO: Expose to extension
        guard
            let pusher = Pusher.shared,
            let build = build
            else { return }
        let events: [PusherEvent] = [.newAction, .updateAction, .updateObservables, .fetchTestResults]
        pusherChannels = build.pusherChannelNames.map {
            pusher.subscribe($0)
        }
        pusherChannels.forEach { channel in
            events.forEach { event in
                channel.bind(event, { [weak self] data in
                    guard var newBuild = self?.build else {
                        self?.loadBuild()
                        return
                    }
                    data.forEach { datum in
                        guard
                            let log = datum["log"] as? [String: Any],
                            let step = datum["step"] as? Int,
                            let index = datum["index"] as? Int,
                            let name = log["name"] as? String,
                            let statusStr = log["status"] as? String,
                            let status = BuildAction.Status(rawValue: statusStr)
                            else { return }
                        switch event {
                        case .updateAction:
                            newBuild = newBuild.build(withNewActionStatus: status, in: index, step: step)
                        case .newAction:
                            let newAction = BuildAction(name: name, index: index, step: step, status: status)
                            var buildStep = newBuild.steps.first {$0.actions.first?.step == step }
                            if buildStep != nil {
                                let actions = buildStep!.actions + [newAction]
                                buildStep = BuildStep(name: name, actions: actions)
                            } else {
                                buildStep = BuildStep(name: name, actions: [newAction])
                            }
                            newBuild = Build(build: newBuild, newSteps: newBuild.steps + [buildStep!])
                        default:
                            break
                        }
                    }
                    self?.build = newBuild
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

    func retryBuild(ssh: Bool = false) {
        guard
            let build = build,
            let nvc = navigationController
            else { return }
        let hud = MBProgressHUD.showAdded(to: nvc.view, animated: true)
        hud.animationType = .fade
        hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        hud.backgroundView.style = .solidColor
        hud.label.text = "Rerunning job"
        URLSession.shared.dataTask(endpoint: .retry(build: build, ssh: ssh)) { [weak self] (build, _, _, err) in
            DispatchQueue.main.async {
                let crashlytics = Crashlytics.sharedInstance()
                hud.mode = .customView
                hud.hide(animated: true, afterDelay: 1)
                guard let build = build else {
                    hud.label.text = "Failed to rerun job"
                    hud.icon = .warning
                    crashlytics.recordError(err ?? APIError.noData)
                    return
                }
                hud.label.text = "Job queued!"
                hud.icon = .success
                guard
                    let storyboard = self?.storyboard,
                    let viewController = storyboard.instantiateViewController(
                        withIdentifier: "BuildActionsViewController")
                        as? BuildActionsViewController
                    else { return }
                viewController.build = build
                nvc.pushViewController(viewController, animated: true)
            }
            }.resume()
    }

    func cancelBuild() {
        guard
            let build = build,
            let nvc = navigationController
            else { return }
        let hud = MBProgressHUD.showAdded(to: nvc.view, animated: true)
        hud.animationType = .fade
        hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        hud.backgroundView.style = .solidColor
        hud.label.text = "Canceling job"
        URLSession.shared.dataTask(endpoint: .cancel(build: build)) { [weak self] (build, _, _, err) in
            DispatchQueue.main.async {
                let crashlytics = Crashlytics.sharedInstance()
                hud.mode = .customView
                hud.hide(animated: true, afterDelay: 1)
                guard let build = build else {
                    hud.label.text = "Failed to cancel job"
                    hud.icon = .warning
                    crashlytics.recordError(err ?? APIError.noData)
                    return
                }
                hud.label.text = "Job canceled!"
                hud.icon = .success
                self?.build = build
            }
            }.resume()
    }

    @IBAction func openActionSheet(_ sender: Any) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let url = build?.compareURL {
            controller.addAction(UIAlertAction(title: "Open diffs in browser", style: .default, handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }
        controller.addAction(UIAlertAction(title: "Rerun job", style: .default, handler: { _ in
            self.retryBuild()
        }))
        if UIApplication.shared.canOpenURL(URL(string: "ssh://foo@dummy.com:1234")!) {
            controller.addAction(UIAlertAction(title: "Rerun job with SSH", style: .default, handler: { _ in
                self.retryBuild(ssh: true)
            }))
        }
        if let build = build, build.status.isLive {
            controller.addAction(UIAlertAction(title: "Cancel job", style: .destructive, handler: { _ in
                self.cancelBuild()
            }))
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
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
            return cell
        }
        if let sshInfo = item.sshInfo {
            cell.textLabel?.text = sshInfo.title
            cell.detailTextLabel?.text = sshInfo.server
            return cell
        }
        if item.isConfiguration {
            cell.textLabel?.text = build?.configurationName
            return cell
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
        guard let view = UINib(nibName: SectionHeaderView.identifier, bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as? SectionHeaderView
            else { fatalError() }
        view.text = self.tableView(tableView, titleForHeaderInSection: section)
        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath),
            let item = diffCalculator?.value(atIndexPath: indexPath) else { return }
        if let sshInfo = item.sshInfo {
            UIApplication.shared.open(sshInfo.url, options: [:], completionHandler: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if cell.selectionStyle == .none {
            return
        }
        if item.segueIdentifier == .showBuildLog {
            performSegue(withIdentifier: item.segueIdentifier, sender: cell)
        }
    }
}

extension BuildActionsViewController {
    struct SSHInfo: Equatable, Comparable {
        let index: Int
        let url: URL

        static func == (_ lhs: SSHInfo, _ rhs: SSHInfo) -> Bool {
            return lhs.index == rhs.index
        }

        static func < (lhs: SSHInfo, rhs: SSHInfo) -> Bool {
            return lhs.index < rhs.index
        }

        var title: String {
            return "Container \(index)"
        }

        var server: String {
            if url.user == "circleci" {
                return String(url.absoluteString.dropFirst("ssh://circleci@".count))
            }
            return String(url.absoluteString.dropFirst("ssh://".count))
        }
    }

    struct RowItem: Equatable, Comparable {
        let action: BuildAction?
        let isConfiguration: Bool
        let isArtifacts: Bool
        let sshInfo: SSHInfo?

        init(
            action: BuildAction? = nil,
            isConfiguration: Bool = false,
            isArtifacts: Bool = false,
            sshInfo: SSHInfo? = nil) {
            self.action = action
            self.isConfiguration = isConfiguration
            self.isArtifacts = isArtifacts
            self.sshInfo = sshInfo
        }

        static func == (_ lhs: RowItem, _ rhs: RowItem) -> Bool {
            if let lobj = lhs.action, let robj = rhs.action {
                return lobj == robj
            }
            if let lobj = lhs.sshInfo, let robj = rhs.sshInfo {
                return lobj == robj
            }
            return lhs.isConfiguration == rhs.isConfiguration && lhs.isArtifacts == rhs.isArtifacts
        }

        static func < (lhs: RowItem, rhs: RowItem) -> Bool {
            if let lobj = lhs.action, let robj = rhs.action {
                return lobj < robj
            }
            if let lobj = lhs.sshInfo, let robj = rhs.sshInfo {
                return lobj < robj
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
            if sshInfo != nil {
                return "SSHCell"
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
