//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/27/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import UIKit
import RealmSwift
import WatchConnectivity
import BigBrother

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, WCSessionDelegate {

    var window: UIWindow?

    lazy var pusherClient: CirclePusherClient = {
        return CirclePusherClient()
    }()

    class var current: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let env = NSProcessInfo().environment

        BigBrother.addToSharedSession()
        setupRealm()

        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }

        // Google Analytics
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
        gai.dispatchInterval = 20
        if env["VERBOSE"] == "1" {
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


    // MARK: - WatchConnectivity

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let fn = message["fn"] as? String where fn == "app-launch" {
            let def = CI2GoUserDefaults.standardUserDefaults()
            if let apiToken = def.circleCIAPIToken
                , colorSchemeName = def.colorSchemeName {
                    session.transferFile(NSURL(fileURLWithPath: realmPath), metadata: [:])
                    replyHandler(
                        [
                            "apiToken": apiToken,
                            "colorSchemeName": colorSchemeName
                        ]
                    )
            }
        }
    }
}

