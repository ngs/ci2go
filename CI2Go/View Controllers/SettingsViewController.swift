//
//  SettingsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import KeychainAccess
import Crashlytics
import Dwifft
import WatchConnectivity
import WebKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    let links: [(String, URL)] = [
        ("Rate CI2Go", URL(string: "https://itunes.apple.com/app/id940028427?action=write-review")!),
        ("Submit an issue", URL(string: "https://github.com/ngs/ci2go/issues/new")!),
        ("Contact author", URL(string: "mailto:corp+ci2go@littleapps.jp?subject=CI2Go%20Support")!)
        ]

    var diffCalculator: TableViewDiffCalculator<String?, RowItem>!

    @IBOutlet weak var doneButtonItem: UIBarButtonItem!

    var isTokenValid: Bool {
        return isValidToken(Keychain.shared.token ?? "")
    }

    func confirmLogout() {
        let av = UIAlertController(title: "Logging out", message: "Are you sure to log out from CircleCI?", preferredStyle: .actionSheet)
        av.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.logout()
        }))
        av.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(av, animated: true, completion: nil)
    }

    func logout() {
        Keychain.shared.token = nil
        let store = WKWebsiteDataStore.default()
        store.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                store.removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
        refreshData()
    }

    func refreshData() {
        let colorSchemeTitle = "Color Scheme"
        let supportTitle = "Support"
        let linkItems: [RowItem] = links.map { .link($0.0, $0.1) }
        var values = [(String?, [RowItem])]()
        if isTokenValid {
            values.append((colorSchemeTitle, [.colorScheme]))
            values.append((supportTitle, linkItems))
            values.append((nil, [.logout]))
        } else {
            values.append((nil, [.auth(.github), .auth(.bitbucket)]))
            values.append((colorSchemeTitle, [.colorScheme]))
            values.append((supportTitle, linkItems))
        }
        diffCalculator.sectionedValues = SectionedValues<String?, RowItem>(values)
    }

    // MARK: - UIViewController

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButtonItem.isEnabled = isTokenValid
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        tableView.register(UINib(nibName: ColorSchemeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ColorSchemeTableViewCell.identifier)
        tableView.register(LoginProviderTableViewCell.self, forCellReuseIdentifier: LoginProviderTableViewCell.identifier)
        refreshData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let vc = segue.destination as? LoginViewController,
            let cell = sender as? LoginProviderTableViewCell,
            let provider = cell.provider
            else { return }
        vc.provider = provider
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
        let v = UINib(nibName: "SettingsFooterView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingsFooterView
        return v
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = diffCalculator.value(atIndexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier)
        switch item {
        case .colorScheme:
            let cell = cell as! ColorSchemeTableViewCell
            cell.colorScheme = ColorScheme.current
            return cell
        case .logout:
            let cell = cell ?? CustomTableViewCell(style: .default, reuseIdentifier: item.cellIdentifier)
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = ColorScheme.current.red
            return cell
        case let .link(title, _):
            let cell = cell ?? CustomTableViewCell(style: .default, reuseIdentifier: item.cellIdentifier)
            cell.textLabel?.text = title
            cell.textLabel?.textColor = ColorScheme.current.foreground
            return cell
        case let .auth(provider):
            let cell = cell as! LoginProviderTableViewCell
            cell.accessoryType = .disclosureIndicator
            cell.provider = provider
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = diffCalculator.value(atIndexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier)
        switch item {
        case .colorScheme:
            performSegue(withIdentifier: .showThemeList, sender: cell)
        case .logout:
            tableView.deselectRow(at: indexPath, animated: true)
            confirmLogout()
        case let .link(_, url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        case let .auth(provider):
            let cell = cell as! LoginProviderTableViewCell
            cell.provider = provider
            performSegue(withIdentifier: .login, sender: cell)
        }
    }

    enum RowItem: Equatable {
        case colorScheme
        case link(String, URL)
        case logout
        case auth(AuthProvider)

        var cellIdentifier: String {
            switch self {
            case .colorScheme:
                return ColorSchemeTableViewCell.identifier
            case .link(_, _):
                return "LinkCell"
            case .logout:
                return "LogoutCell"
            case .auth(_):
                return LoginProviderTableViewCell.identifier
            }
        }
    }
}
