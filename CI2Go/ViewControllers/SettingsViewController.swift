//
//  SettingsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import KeychainAccess
import Dwifft
import WatchConnectivity
import WebKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    var links: [(String, URL)] {

        #if targetEnvironment(macCatalyst)
        return [
            ("Trouble signing in?",
             URL(string: "https://ci2go.app/support/token-uri-scheme/?b=\(Bundle.main.buildNumber)")!)
        ]
        #else
        return [
            ("Trouble signing in?",
             URL(string: "https://ci2go.app/support/token-uri-scheme/?b=\(Bundle.main.buildNumber)")!),
            ("Rate CI2Go",
             URL(string: "https://itunes.apple.com/app/id940028427?action=write-review")!),
            ("Submit an issue", Bundle.main.submitIssueURL),
            ("Contact author", Bundle.main.contactURL)
        ]
        #endif
    }

    var diffCalculator: TableViewDiffCalculator<String?, RowItem>!

    @IBOutlet weak var doneButtonItem: UIBarButtonItem!

    var isTokenValid: Bool {
        return isValidToken(Keychain.shared.token ?? "")
    }

    func confirmLogout() {
        let alert = UIAlertController(
            title: "Logging out",
            message: "Are you sure to logout from CircleCI?",
            preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func logout() {
        Keychain.shared.token = nil
        isModalInPresentation = true
        let store = WKWebsiteDataStore.default()
        store.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                store.removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
        self.refreshData()
    }

    func refreshData() {
        var supportTitle: String?
        #if targetEnvironment(macCatalyst)
        supportTitle = nil
        #else
        supportTitle = "Support"
        #endif
        let linkItems: [RowItem] = links.map { .link($0.0, $0.1) }
        var values = [(String?, [RowItem])]()
        if isTokenValid {
            values.append((nil, []))
            values.append((supportTitle, linkItems))
            values.append((nil, [.logout]))
        } else {
            values.append((nil, [.auth(.github), .auth(.bitbucket)]))
            values.append((supportTitle, linkItems))
        }
        navigationItem.rightBarButtonItem?.isEnabled = isTokenValid
        diffCalculator.sectionedValues = SectionedValues<String?, RowItem>(values)
    }

    // MARK: - UIViewController

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButtonItem.isEnabled = isTokenValid
        tableView.reloadData()
        if Keychain.shared.token == nil {
            logout()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        tableView.register(
            LoginProviderTableViewCell.self,
            forCellReuseIdentifier: LoginProviderTableViewCell.identifier)
        refreshData()
    }

    override func viewDidAppear(_ animated: Bool) {
        isModalInPresentation = !isTokenValid
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let viewController = segue.destination as? LoginViewController,
            let cell = sender as? LoginProviderTableViewCell,
            let provider = cell.provider
            else { return }
        viewController.provider = provider
    }

    // MARK: - UITableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator.numberOfObjects(inSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return diffCalculator.value(forSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard numberOfSections(in: tableView) - 1 == section else { return 0 }
        return SettingsFooterView.height
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard numberOfSections(in: tableView) - 1 == section else { return nil }
        guard let view = UINib(nibName: "SettingsFooterView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as? SettingsFooterView
            else { fatalError() }
        return view
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = diffCalculator.value(atIndexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier)
        switch item {
        case .logout:
            let cell = cell ?? CustomTableViewCell(style: .default, reuseIdentifier: item.cellIdentifier)
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            return cell
        case let .link(title, _):
            let cell = cell ?? CustomTableViewCell(style: .default, reuseIdentifier: item.cellIdentifier)
            cell.textLabel?.text = title
            cell.textLabel?.textColor = .label
            return cell
        case let .auth(provider):
            guard let cell = cell as? LoginProviderTableViewCell else {
                fatalError()
            }
            cell.accessoryType = .disclosureIndicator
            cell.provider = provider
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = diffCalculator.value(atIndexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier)
        switch item {
        case .logout:
            tableView.deselectRow(at: indexPath, animated: true)
            confirmLogout()
        case let .link(_, url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        case let .auth(provider):
            guard let cell = cell as? LoginProviderTableViewCell else {
                fatalError()
            }
            cell.provider = provider
            performSegue(withIdentifier: .login, sender: cell)
        }
    }

    enum RowItem: Equatable {
        case link(String, URL)
        case logout
        case auth(AuthProvider)

        var cellIdentifier: String {
            switch self {
            case .link:
                return "LinkCell"
            case .logout:
                return "LogoutCell"
            case .auth:
                return LoginProviderTableViewCell.identifier
            }
        }
    }
}
