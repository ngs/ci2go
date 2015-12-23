//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import AFNetworking
import MagicalRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

  var window: UIWindow?
  var dbInitialized = false

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    // Google Analytics
    let gai = GAI.sharedInstance()
    gai.trackUncaughtExceptions = true
    gai.dispatchInterval = 20
    if NSProcessInfo().environment["VERBOSE"] == "1" {
      gai.logger.logLevel = .Verbose
    }
    gai.trackerWithTrackingId(kCI2GoGATrackingId)

    //

    initializeDB()

    // AFNetworking
    AFNetworkActivityIndicatorManager.sharedManager().enabled = true

    // Appearance
    ColorScheme().apply()

    // Setup view controllers
    let splitViewController = self.window!.rootViewController as! UISplitViewController
    let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
    navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
    splitViewController.delegate = self

    return true
  }

  func applicationWillTerminate(application: UIApplication) {
    NSManagedObjectContext.MR_defaultContext().saveToPersistentStoreAndWait()
  }

  // MARK: - Split view

  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
      if secondaryAsNavController.topViewController is BuildLogViewController {
        return true
      }
    }
    return false
  }

  func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
    return false
  }

  // MARK: - Magical Record

  func initializeDB() {
    if !dbInitialized {
      let env = NSProcessInfo().environment
      let dbName = env["DB_NAME"] ?? "CI2Go"
      let dbURL = NSFileManager.defaultManager()
        .containerURLForSecurityApplicationGroupIdentifier(kCI2GoAppGroupIdentifier)?
        .URLByAppendingPathComponent(dbName + ".sqlite")
      MagicalRecord.enableShorthandMethods()
      MagicalRecord.setupCoreDataStackWithStoreAtURL(dbURL)
      dbInitialized = true
    }
  }
  
}

