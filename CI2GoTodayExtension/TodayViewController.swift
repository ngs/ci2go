//
//  TodayViewController.swift
//  CI2GoTodayExtension
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import NotificationCenter
import Crashlytics
import Dwifft
import KeychainAccess

class TodayViewController: UITableViewController, NCWidgetProviding {
    let limit = 5

    var diffCalculator: TableViewDiffCalculator<Int, Build>!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: BuildTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: BuildTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        diffCalculator.insertionAnimation = .none
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        guard let token = Keychain.shared.token else {
            completionHandler(.noData)
            return
        }
        let limit = self.limit
        let defaults = UserDefaults.shared
        let object: EndpointConvertable? = defaults.branch ?? defaults.project
        let endpoint: Endpoint<[Build]> = .builds(object: object, offset: 0, limit: limit)
        let diffCalculator = self.diffCalculator
        URLSession.shared.dataTask(endpoint: endpoint, token: token) { [weak self] (builds, _, _, err) in
            guard let `self` = self else { return }
            if let err = err {
                Crashlytics.sharedInstance().recordError(err)
                completionHandler(.failed)
                return
            }
            let oldBuilds: [Build] = diffCalculator?.sectionedValues.sectionsAndValues.first?.1 ?? []
            let newBuilds: [Build] = Array(oldBuilds.merged(with: builds ?? []).sorted().reversed().prefix(limit))
            DispatchQueue.main.async {
                self.diffCalculator.sectionedValues = SectionedValues<Int, Build>([(0, newBuilds)])
                self.updatePreferredContentSize()
                self.tableView.reloadData()
                completionHandler(.newData)
            }
        }.resume()
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        updatePreferredContentSize(for: activeDisplayMode, width: maxSize.width)
    }

    func numberOfRows(for activeDisplayMode: NCWidgetDisplayMode) -> Int {
        switch activeDisplayMode {
        case .compact:
            return 2
        case .expanded:
            return limit
        }
    }

    func updatePreferredContentSize(for activeDisplayMode: NCWidgetDisplayMode? = nil, width: CGFloat? = nil) {
        guard let activeDisplayMode = activeDisplayMode ?? self.extensionContext?.widgetActiveDisplayMode else {
            return
        }
        let width = width ?? preferredContentSize.width
        let builds: [Build] = diffCalculator?.sectionedValues.sectionsAndValues.first?.1 ?? []
        let limit = numberOfRows(for: activeDisplayMode)
        let sum = builds.prefix(limit).reduce(CGFloat(20)) { (num, build) -> CGFloat in
            return num + BuildTableViewCell.height(for: build)
        }
        preferredContentSize = CGSize(width: width, height: sum)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator.numberOfObjects(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = diffCalculator.value(atIndexPath: indexPath)
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BuildTableViewCell.identifier) as? BuildTableViewCell
            else { fatalError() }
        cell.build = item
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = diffCalculator.value(atIndexPath: indexPath)
        return BuildTableViewCell.height(for: item)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = diffCalculator.value(atIndexPath: indexPath).inAppURL
        extensionContext?.open(url, completionHandler: { _ in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
    }

}
