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
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    var isTokenValid: Bool {
        return isValidToken(Keychain.shared.token ?? "")
    }

    var colorSchemeSection: Int {
        return isTokenValid ? 0 : 1
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorSchemeSection == section ? 1 : isTokenValid ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == colorSchemeSection {
            return "Color Scheme"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section == 1 else { return 0 }
        return 300
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }
        let v = UINib(nibName: "SettingsFooterView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingsFooterView
        return v
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == colorSchemeSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: ColorSchemeTableViewCell.identifier) as! ColorSchemeTableViewCell
            cell.colorScheme = ColorScheme.current
            return cell
        }
        if isTokenValid {
            let identifier = "LogoutCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = ColorScheme.current.red
            cell.textLabel?.text = "Logout"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: LoginProviderTableViewCell.identifier) as! LoginProviderTableViewCell
        cell.provider = AuthProvider(rawValue: indexPath.row)!
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == colorSchemeSection {
            performSegue(withIdentifier: .showThemeList, sender: cell)
            return
        }
        if isTokenValid {
            tableView.deselectRow(at: indexPath, animated: true)
            confirmLogout()
            return
        }
        performSegue(withIdentifier: .login, sender: cell)
    }
}
