//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, PTPusherDelegate {

  var window: UIWindow?
  var dbInitialized = false
  var pusher: PTPusher?;

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    // Google Analytics
    let gai = GAI.sharedInstance()
    gai.trackUncaughtExceptions = true
    gai.dispatchInterval = 20
    if (NSProcessInfo().environment["VERBOSE"] as? String) == "1" {
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
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
    splitViewController.delegate = self

    pusher = PTPusher.pusherWithKey(kCI2GoPusherAPIKey, delegate: self, encrypted: true) as? PTPusher
    if let token = CI2GoUserDefaults.standardUserDefaults().circleCIAPIToken as? String {
      pusher?.authorizationURL = NSURL(string: kCI2GoPusherAuthorizationURL + token)
      pusher?.connect()
    }
    return true
  }

  func applicationWillTerminate(application: UIApplication) {
    NSManagedObjectContext.MR_defaultContext().saveToPersistentStoreAndWait()
    pusher?.disconnect()
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
      let env = NSProcessInfo().environment
      var dbName = env["DB_NAME"] as? String
      if dbName == nil {
        dbName = "CI2Go"
      }
      let dbURL = NSFileManager.defaultManager()
        .containerURLForSecurityApplicationGroupIdentifier(kCI2GoAppGroupIdentifier)?
        .URLByAppendingPathComponent(dbName! + ".sqlite")
      MagicalRecord.enableShorthandMethods()
      MagicalRecord.setupCoreDataStackWithStoreAtURL(dbURL)
      dbInitialized = true
    }
  }

  static var current: AppDelegate {
    get {
      return UIApplication.sharedApplication().delegate as! AppDelegate
    }
  }

  func pusher(pusher: PTPusher!, connection: PTPusherConnection!, didDisconnectWithError error: NSError!, willAttemptReconnect: Bool) {
    if !willAttemptReconnect {
      handleDisconnectionWithError(error)
    }

  }

  func pusher(pusher: PTPusher!, connection: PTPusherConnection!, failedWithError error: NSError!) {
    handleDisconnectionWithError(error)
  }

  func handleDisconnectionWithError(error: NSError!) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC))),
      dispatch_get_main_queue(), {
        self.pusher?.connect()
    });
  }

}

