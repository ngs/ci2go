//
//  WKInterfaceController+initializeDB.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit

var dbInitialized = false

extension WKInterfaceController {

  // MARK: - Google Analytics

  func getDefaultGAITraker() -> GAITracker {
    let gai = GAI.sharedInstance()
    gai.trackUncaughtExceptions = true
    gai.dispatchInterval = 20
    if (NSProcessInfo().environment["VERBOSE"] as? String) == "1" {
      gai.logger.logLevel = .Verbose
    }
    gai.trackerWithTrackingId(kCI2GoGATrackingId)
    return gai!.defaultTracker
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
}
