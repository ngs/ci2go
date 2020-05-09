//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/14.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible

        ColorScheme.current.apply()
        activateWCSession()
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard
            let splitVC = window?.rootViewController as? MainSplitViewController,
            let viewController = splitVC.buildsViewController
            else { return false }

        if let build = Build(inAppURL: url) ?? Build(webURL: url) {
            viewController.navigationController?.popToViewController(viewController, animated: false)
            viewController.performSegue(withIdentifier: .showBuildDetail, sender: build)
            return true
        }
        if url.host == inAppHost &&
            url.pathComponents.count == 3 &&
            url.pathComponents[1] == "token" {
            let token = url.pathComponents[2]
            viewController.logout(showSettings: false)
            viewController.presentedViewController?.dismiss(animated: false, completion: nil)
            Keychain.shared.setAndTransfer(token: token)
            viewController.navigationController?.popToViewController(viewController, animated: false)
            return true
        }
        return false
    }

    // MARK: - Split View

    var splitViewController: UISplitViewController? {
        return window?.rootViewController as? UISplitViewController
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            let viewController = secondaryAsNavController.topViewController
            return viewController is BuildLogViewController || viewController is TextViewController
        }
        return false
    }
}
