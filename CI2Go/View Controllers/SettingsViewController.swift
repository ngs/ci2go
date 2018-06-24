//
//  SettingsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import KeychainAccess
import MBProgressHUD
import Crashlytics
import WatchConnectivity

class SettingsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    @IBOutlet weak var apiTokenField: UITextField!
    private var isTokenModified = false
    var foregroundObserver: NSObjectProtocol?

    lazy var apiTokenCaptionView: APITokenCaptionView = {
        return UINib(nibName: "APITokenCaptionView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as! APITokenCaptionView
    }()

    // MARK: - UIViewController

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scheme = ColorScheme.current
        let token = Keychain.shared.token ?? ""
        let isValid = isValidToken(token)
        apiTokenField.setValue(scheme.placeholder, forKeyPath: "_placeholderLabel.textColor")
        apiTokenField.text = token
        cancelButtonItem.isEnabled = isValid
        doneButtonItem.isEnabled = isValid
        tableView.isScrollEnabled = false
        tableView.reloadData()
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationWillEnterForeground,
            object: nil,
            queue: nil) { [weak self] _ in
                self?.fillTokenFromPasteboard()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: ColorSchemeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ColorSchemeTableViewCell.identifier)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        apiTokenField.resignFirstResponder()
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
        foregroundObserver = nil
    }

    // MARK: - IBActions

    func fillTokenFromPasteboard() {
        let pb = UIPasteboard.general
        guard
            let str = pb.string,
            let m = tokenRegularExpression.firstMatch(
                in: str,
                options: NSRegularExpression.MatchingOptions(rawValue: 0),
                range: NSRange(location: 0, length: str.count)),
            m.numberOfRanges > 0
            else { return }
        let range = m.range(at: 0)
        let substr = str[str.index(str.startIndex, offsetBy: range.location)..<str.index(str.startIndex, offsetBy: range.location + range.length)]
        let av = UIAlertController(
            title: "Found token from clipboard",
            message: "String matching API token was found in your clipboard.\n\n\(substr)\n\nWould you like to use this as CircleCI API token?",
            preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.apiTokenField.text = String(substr)
            self.validateAPIToken(dismissAfterSuccess: true)
        }))
        av.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(av, animated: true, completion: nil)
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        if Keychain.shared.token == apiTokenField.text {
            dismiss(animated: true, completion: nil)
        } else {
            validateAPIToken(dismissAfterSuccess: true)
        }
    }
    private func validateAPIToken(dismissAfterSuccess: Bool = false) {
        guard
            let navigationView = navigationController?.view,
            let token = apiTokenField.text
            else { return }
        let hud = MBProgressHUD.showAdded(to: navigationView, animated: true)
        hud.animationType = .fade
        hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        hud.backgroundView.style = .solidColor
        hud.label.text = "Authenticating"
        hud.show(animated: true)
        URLSession.shared.dataTask(endpoint: .me, token: token) { [weak self] (user, _, _, err) in
            DispatchQueue.main.async {
                let crashlytics = Crashlytics.sharedInstance()
                hud.mode = .customView
                hud.hide(animated: true, afterDelay: 1)
                guard let user = user else {
                    hud.label.text = "Failed to authenticate"
                    hud.icon = .warning
                    crashlytics.recordError(err ?? APIError.noData)
                    Answers.logLogin(withMethod: nil, success: false, customAttributes: nil)
                    return
                }
                Keychain.shared.token = token
                WCSession.default.transferToken(token: token)
                hud.label.text = "Authenticated"
                hud.icon = .success
                crashlytics.setUserIdentifier(user.login)
                crashlytics.setUserName(user.name)
                Answers.logLogin(withMethod: nil, success: true, customAttributes: nil)
                if dismissAfterSuccess {
                    self?.dismiss(animated: true)
                }
            }
            }.resume()
    }

    // MARK: - UITableView

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ColorSchemeTableViewCell.identifier) as! ColorSchemeTableViewCell
            cell.colorScheme = ColorScheme.current
            return cell
        }
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 0 ? apiTokenCaptionView : nil
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            performSegue(withIdentifier: .showThemeList, sender: nil)
        }
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        guard let stringRange = Range(range, in: text) else { return true }

        let nextString = text.replacingCharacters(in: stringRange, with: string)
        doneButtonItem.isEnabled = isValidToken(nextString)
        if nextString.lengthOfBytes(using: .utf8) > 40 {
            return false
        }
        let set = NSCharacterSet(charactersIn: "abcdef1234567890").inverted
        if let _ = nextString.rangeOfCharacter(from: set) {
            return false
        }
        isTokenModified = true
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, isValidToken(text) {
            validateAPIToken()
            return true
        }
        return false
    }
}
