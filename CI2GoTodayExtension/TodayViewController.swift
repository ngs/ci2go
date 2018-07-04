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

class TodayViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var controlViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlView: UIStackView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    let limit = 5

    var diffCalculator: TableViewDiffCalculator<Int, Build>!

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: BuildTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: BuildTableViewCell.identifier)
        if diffCalculator == nil {
            diffCalculator = TableViewDiffCalculator(tableView: tableView)
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        if let cache = [Build].fromCache() {
            diffCalculator.sectionedValues = SectionedValues<Int, Build>([(0, cache)])
        }
        if let date = [Build].cacheFile.modifiedDate {
            updatedTimeLabel.text = "Last update " + dateFormatter.string(from: date)
        } else {
            updatedTimeLabel.text = ""
        }
    }

    @IBAction func refresh(_ sender: Any) {
        loadBuilds()
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
        let builds: [Build] = diffCalculator?.sectionedValues.sectionsAndValues.first?.1 ?? []
        guard
            let activeDisplayMode = activeDisplayMode ?? self.extensionContext?.widgetActiveDisplayMode,
            !builds.isEmpty else {
            return
        }
        let width = width ?? preferredContentSize.width

        let limit = numberOfRows(for: activeDisplayMode)
        let isHidden = activeDisplayMode == .compact
        controlView.isHidden = isHidden
        controlViewHeightConstraint.constant = controlView.isHidden ? 0 : 40
        let sum = builds.prefix(limit).reduce(controlViewHeightConstraint.constant) { (num, build) -> CGFloat in
            return num + BuildTableViewCell.height(for: build)
        }
        preferredContentSize = CGSize(width: width, height: sum)
    }

    func loadBuilds(completionHandler: ((NCUpdateResult) -> Void)? = nil) {
        guard let token = Keychain.shared.token else {
            completionHandler?(.noData)
            return
        }
        self.updatePreferredContentSize()
        let limit = self.limit
        let defaults = UserDefaults.shared
        let object: EndpointConvertable? = defaults.branch ?? defaults.project
        let endpoint: Endpoint<[Build]> = .builds(object: object, offset: 0, limit: limit)
        let diffCalculator = self.diffCalculator
        refreshButton.isHidden = true
        activityIndicatorView.startAnimating()
        URLSession.shared.dataTask(endpoint: endpoint, token: token) { [weak self] (builds, data, _, err) in
            DispatchQueue.main.async {
                self?.refreshButton.isHidden = false
                self?.activityIndicatorView.stopAnimating()
            }
            guard let builds = builds else {
                Crashlytics.sharedInstance().recordError(err ?? APIError.noData)
                completionHandler?(.failed)
                return
            }
            guard let `self` = self else {
                completionHandler?(.failed)
                return
            }
            try? [Build].wtriteCache(data: data)
            let oldBuilds: [Build] = diffCalculator?.sectionedValues.sectionsAndValues.first?.1 ?? []
            let newBuilds: [Build] = Array(oldBuilds.merged(with: builds).sorted().reversed().prefix(limit))
            DispatchQueue.main.async {
                self.diffCalculator.sectionedValues = SectionedValues<Int, Build>([(0, newBuilds)])
                self.updatePreferredContentSize()
                self.updatedTimeLabel.text = "Last update: " + self.dateFormatter.string(from: Date())
                completionHandler?(.newData)
            }
            }.resume()
    }

}

extension TodayViewController: NCWidgetProviding {

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        loadBuilds(completionHandler: completionHandler)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        updatePreferredContentSize(for: activeDisplayMode, width: maxSize.width)
    }
}

extension TodayViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator.numberOfObjects(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = diffCalculator.value(atIndexPath: indexPath)
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BuildTableViewCell.identifier) as? BuildTableViewCell
            else { fatalError() }
        cell.build = item
        cell.tintColor = .darkText
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = diffCalculator.value(atIndexPath: indexPath)
        return BuildTableViewCell.height(for: item)
    }
}

extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = diffCalculator.value(atIndexPath: indexPath).inAppURL
        extensionContext?.open(url, completionHandler: { _ in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
    }
}
