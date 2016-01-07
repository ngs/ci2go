//
//  ExtensionDelegate.swift
//  CI2Go WatchKit App Extension
//
//  Created by Atsushi Nagase on 12/27/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import WatchConnectivity

let kCI2GoAPITokenReceivedNotification = "CI2GoAPITokenReceived"

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    func applicationDidFinishLaunching() {
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    func applicationDidBecomeActive() {
        let session = WCSession.defaultSession()
        session.sendMessage(function: .AppLaunch, replyHandler: { res in
            if let apiToken = res[kCI2GoWatchConnectivityApiTokenKey] as? String
                , colorSchemeName = res[kCI2GoWatchConnectivityColorSchemeNameKey] as? String {
                    let def = CI2GoUserDefaults.standardUserDefaults()
                    def.circleCIAPIToken = apiToken
                    def.colorSchemeName = colorSchemeName
                    NSNotificationCenter.defaultCenter()
                        .postNotificationName(kCI2GoAPITokenReceivedNotification, object: nil)
            }
        })
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
}
