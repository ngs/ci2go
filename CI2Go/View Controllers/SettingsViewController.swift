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

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    var isTokenValid: Bool {
        return isValidToken(Keychain.shared.token ?? "")
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
        return isTokenValid ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTokenValid || section == 1 {
            return 1
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isTokenValid || section == 1 {
            return "Color Scheme"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 || isTokenValid {
            let cell = tableView.dequeueReusableCell(withIdentifier: ColorSchemeTableViewCell.identifier) as! ColorSchemeTableViewCell
            cell.colorScheme = ColorScheme.current
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: LoginProviderTableViewCell.identifier) as! LoginProviderTableViewCell
        cell.provider = LoginViewController.Provider(rawValue: indexPath.row)!
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if isTokenValid || indexPath.section == 1 {
            performSegue(withIdentifier: .showThemeList, sender: cell)
            return
        }
        performSegue(withIdentifier: .login, sender: cell)
    }
}
