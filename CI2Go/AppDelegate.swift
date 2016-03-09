//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/27/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import UIKit
import RealmSwift
import BigBrother
import RxSwift
import Alamofire
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    let disposeBag = DisposeBag()
    let watchMessageHandler = WatchMessageHandler()
    
    lazy var pusherClient: CirclePusherClient = {
        return CirclePusherClient()
    }()

    var realmPath: String {
        let env = NSProcessInfo.processInfo().environment
        let dbName = env["REALM_DB_NAME"]
        let m = NSFileManager.defaultManager()
        let fileURL = m
            .containerURLForSecurityApplicationGroupIdentifier(kCI2GoAppGroupIdentifier)!
            .URLByAppendingPathComponent(dbName ?? "ci2go.realm")
        if env["CLEAR_REALM_DB"] == "1" && m.fileExistsAtPath(fileURL.path!) {
            try! m.removeItemAtURL(fileURL)
        }
        return fileURL.path!
    }

    func setupRealm() {
        let env = NSProcessInfo().environment

        var config = Realm.Configuration(
            schemaVersion: kCI2GoSchemaVersion,
            migrationBlock: { _, _ in }
        )
        if let identifier = env["REALM_MEMORY_IDENTIFIER"] {
            config.inMemoryIdentifier = identifier
        } else {
            config.path = realmPath
        }
        Realm.Configuration.defaultConfiguration = config
    }

    class var current: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self, Answers.self])
        let env = NSProcessInfo().environment
        if env["TEST"] != "1" {
            BigBrother.addToSharedSession()
            BigBrother.addToSessionConfiguration(Alamofire.Manager.sharedInstance.session.configuration)
        }
        setupRealm()
        watchMessageHandler.activate()
        
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
        splitViewController?.delegate = self
        let navigationController = splitViewController?.viewControllers.last as? UINavigationController
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()

        return true
    }

    var splitViewController: UISplitViewController? {
        return self.window?.rootViewController as? UISplitViewController
    }
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            let vc = secondaryAsNavController.topViewController
            return vc is BuildLogViewController || vc is TextViewController
        }
        return false
    }
    
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
}

