//
//  ExtensionDelegate.swift
//  CI2Go WatchKit App Extension
//
//  Created by Atsushi Nagase on 12/27/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import WatchConnectivity

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
        session.sendMessage(["fn":"app-launch"], replyHandler: { res in
            if let apiToken = res["apiToken"] as? String
                , colorSchemeName = res["colorSchemeName"] as? String {
                    let def = CI2GoUserDefaults.standardUserDefaults()
                    def.circleCIAPIToken = apiToken
                    def.colorSchemeName = colorSchemeName
                    NSNotificationCenter.defaultCenter().postNotificationName("hoge", object: nil)
            }
            }, errorHandler: nil)
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    // MARK: - WCSessionDelegate

    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        let m = NSFileManager.defaultManager()
        guard let path1 = file.fileURL.path else { return }
        let dest = realmPath
        if m.fileExistsAtPath(dest) {
            try! m.removeItemAtPath(dest)
        }
        try! m.moveItemAtPath(path1, toPath: dest)
        setupRealm()
    }
}
