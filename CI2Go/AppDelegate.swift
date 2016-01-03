//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/27/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    lazy var realm: Realm = {
        return try! Realm()
    }()

    class var current: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Google Analytics
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
        gai.dispatchInterval = 20
        if NSProcessInfo().environment["VERBOSE"] == "1" {
            gai.logger.logLevel = .Verbose
        }
        gai.trackerWithTrackingId(kCI2GoGATrackingId)

        // Appearance
        ColorScheme().apply()

        // Setup view controllers
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self

        return true
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            return secondaryAsNavController.topViewController is BuildLogViewController
        }
        return false
    }

    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }

}

