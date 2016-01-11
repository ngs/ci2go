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

    class var current: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let env = NSProcessInfo().environment
        
        BigBrother.addToSharedSession()
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

    func setupRealm() {
        let env = NSProcessInfo().environment

        var config = Realm.Configuration(schemaVersion: kCI2GoSchemaVersion)
        if let identifier = env["REALM_MEMORY_IDENTIFIER"] {
            config.inMemoryIdentifier = identifier
        } else {
            config.path = realmPath
        }
        let def = CI2GoUserDefaults.standardUserDefaults()
        if def.storedSchemaVersion != kCI2GoSchemaVersion {
            if let path = Realm.Configuration.defaultConfiguration.path {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                } catch {}
            }
            _ = try! Realm()
            def.storedSchemaVersion = kCI2GoSchemaVersion
        }
        Realm.Configuration.defaultConfiguration = config
    }
    
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
}

