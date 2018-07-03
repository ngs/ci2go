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
import WatchConnectivity
import WebKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    let links: [(String, URL)] = [
        ("Rate CI2Go", URL(string: "https://itunes.apple.com/app/id940028427?action=write-review")!),
        ("Submit an issue", URL(string: "https://github.com/ngs/ci2go/issues/new")!),
        ("Contact author", URL(string: "mailto:corp+ci2go@littleapps.jp?subject=CI2Go%20Support")!),
        ]

    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    var isTokenValid: Bool {
        return isValidToken(Keychain.shared.token ?? "")
    }

    var colorSchemeSection: Int {
        return isTokenValid ? 0 : 1
    }

    var linksSection: Int {
        return isTokenValid ? 1 : 2
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
        tableView.reloadData()
    }

    // MARK: - UIViewController

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButtonItem.isEnabled = isTokenValid
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: ColorSchemeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ColorSchemeTableViewCell.identifier)
        tableView.register(LoginProviderTableViewCell.self, forCellReuseIdentifier: LoginProviderTableViewCell.identifier)
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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case colorSchemeSection:
            return 1
        case linksSection:
            return links.count
        default:
            return isTokenValid ? 1 : 2
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case colorSchemeSection:
            return "Color Scheme"
        case linksSection:
            return "Support"
        default:
            return nil
        }
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
        switch indexPath.section {
        case colorSchemeSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: ColorSchemeTableViewCell.identifier) as! ColorSchemeTableViewCell
            cell.colorScheme = ColorScheme.current
            return cell
        case linksSection:
            let identifier = "LinkCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? CustomTableViewCell(style: .default, reuseIdentifier: identifier)
            cell.textLabel?.text = links[indexPath.row].0
            cell.textLabel?.textColor = ColorScheme.current.foreground
            return cell
        default:
            if isTokenValid {
                let identifier = "LogoutCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? CustomTableViewCell(style: .default, reuseIdentifier: identifier)
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = ColorScheme.current.red
                cell.textLabel?.text = "Logout"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: LoginProviderTableViewCell.identifier) as! LoginProviderTableViewCell
            cell.provider = AuthProvider(rawValue: indexPath.row)!
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        switch indexPath.section {
        case colorSchemeSection:
            performSegue(withIdentifier: .showThemeList, sender: cell)
            return
        case linksSection:
            let url = links[indexPath.row].1
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        default:
            if isTokenValid {
                tableView.deselectRow(at: indexPath, animated: true)
                confirmLogout()
                return
            }
            performSegue(withIdentifier: .login, sender: cell)
        }
    }
}
