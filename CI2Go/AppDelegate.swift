//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/14.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        activateWCSession()
        return true
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        guard builder.system == .main else { return }

        builder.remove(menu: .format)
        builder.remove(menu: .file)
        builder.remove(menu: .toolbar)
        builder.insertSibling(.logout, afterMenu: .about)
        builder.insertSibling(.navigate, afterMenu: .edit)
        builder.replaceChildren(ofMenu: .help) { _ in
            [
                UIMenu(
                    title: "",
                    image: nil,
                    identifier: UIMenu.Identifier("com.ci2go.menu.Homepage"),
                    options: .displayInline,
                    children: [UIAction(title: "CI2Go Homepage") { _ in
                        UIApplication.shared.open(URL(string: "https://ci2go.app")!)
                        }]),
                UIAction(title: "Submit an Issue") { _ in
                    UIApplication.shared.open(Bundle.main.submitIssueURL)
                },
                UIAction(title: "Contact Author") { _ in
                    UIApplication.shared.open(Bundle.main.contactURL)
                }
            ]
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            .back,
            .logoutCommand,
            .reload
        ]
    }

    @objc func backAction(_ command: UIKeyCommand) {
        MainSplitViewController.current?
            .firstNavigationController?
            .popViewController(animated: true)
    }

    @objc func reloadAction(_ command: UIKeyCommand) {
        (MainSplitViewController.current?
            .firstNavigationController?
            .viewControllers.first
            as? ReloadableViewController)?.reload()
    }

    @objc func logoutAction(_ command: UIKeyCommand) {
        guard let splitVC = MainSplitViewController.current else { return }
        let alertView = UIAlertController(
            title: "Logging out",
            message: "Are you sure to logout from CircleCI?",
            preferredStyle: .alert)
        alertView.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel, handler: nil))
        alertView.addAction(UIAlertAction(
            title: "Yes, log me out",
            style: .destructive, handler: { _ in
                splitVC.buildsViewController?.logout()
        }))
        splitVC.present(alertView, animated: true)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard let splitVC = MainSplitViewController.current else {
            return false
        }
        if
            action == #selector(AppDelegate.backAction(_:)),
            let count = splitVC.firstNavigationController?.viewControllers.count {
            return count > 1
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
