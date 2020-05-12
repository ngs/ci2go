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
        builder.insertSibling(.reload, afterMenu: .toolbar)
        builder.remove(menu: .toolbar)
        builder.insertSibling(.preferences, afterMenu: .about)
        builder.insertSibling(.navigation, afterMenu: .application)
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            .back,
            .preferencesCommand,
            .reloadCommand
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

    @objc func preferencesAction(_ command: UIKeyCommand) {
        MainSplitViewController.current?
            .buildsViewController?
            .performSegue(withIdentifier: .showSettings, sender: command)
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
