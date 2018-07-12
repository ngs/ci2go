//
//  BuildActionsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import Dwifft
import PusherSwift

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
        unsubscribePusher()
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

    func scrollToBottom(animated: Bool = false) {
        let section = numberOfSections(in: tableView) - 1
        let row = tableView(tableView, numberOfRowsInSection: section) - 1
        let diff = tableView.bounds.height + tableView.contentOffset.y - tableView.contentSize.height
        if section >= 0 && row >= 0 && diff < tableView.rowHeight {
            tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: animated)
        }
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
        controller.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
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
