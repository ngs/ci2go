//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

  var window: UIWindow?
  var dbInitialized = false

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    initializeDB()

    // AFNetworking
    AFNetworkActivityIndicatorManager.sharedManager().enabled = true

    // Appearance
    ColorScheme().apply()

    // Setup view controllers
    let splitViewController = self.window!.rootViewController as UISplitViewController
    let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as UINavigationController
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
    splitViewController.delegate = self

    return true
  }

  func applicationWillTerminate(application: UIApplication) {
    NSManagedObjectContext.MR_defaultContext().saveToPersistentStoreAndWait()
  }

  // MARK: - Split view

  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
      if let topAsDetailController = secondaryAsNavController.topViewController as? BuildLogViewController {
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
      let dbURL = NSFileManager.defaultManager()
        .containerURLForSecurityApplicationGroupIdentifier(kCI2GoAppGroupIdentifier)?
        .URLByAppendingPathComponent("CI2Go.sqlite")
      MagicalRecord.setupCoreDataStackWithStoreAtURL(dbURL)
      dbInitialized = true
    }
  }
  
}

