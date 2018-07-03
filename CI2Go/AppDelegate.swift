//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/14.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import Crashlytics
import Fabric
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible

        ColorScheme.current.apply()
        activateWCSession()
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        guard
            let build = Build(inAppURL: url),
            let splitVC = window?.rootViewController as? UISplitViewController,
            let viewController: BuildsViewController = splitVC.viewControllers
                .map({ (viewController: UIViewController) -> BuildsViewController? in
                    guard
                        let nvc = viewController as? UINavigationController,
                        let viewController = nvc.viewControllers.first as? BuildsViewController
                        else { return nil }
                    return viewController
                })
                .first(where: { $0 != nil }) as? BuildsViewController
            else { return false }

        viewController.navigationController?.popToViewController(viewController, animated: false)
        viewController.performSegue(withIdentifier: .showBuildDetail, sender: build)
        return true
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
