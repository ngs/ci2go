//
//  GlanceController.swift
//  CI2Go WatchKit Extension
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

class GlanceController: SingleBuildInterfaceController, WCSessionDelegate {
    @IBOutlet weak var placeholderLabel: WKInterfaceLabel!
    private var isLoading = true
    override func willActivate() {
        super.willActivate()
        updateViews()
        guard WCSession.isSupported() else { return }
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        session.sendMessage(function: .AppLaunch, replyHandler: { res in
            if let apiToken = res[kCI2GoWatchConnectivityApiTokenKey] as? String
                , colorSchemeName = res[kCI2GoWatchConnectivityColorSchemeNameKey] as? String {
                    let def = CI2GoUserDefaults.standardUserDefaults()
                    def.circleCIAPIToken = apiToken
                    def.colorSchemeName = colorSchemeName
                    NSNotificationCenter.defaultCenter()
                        .postNotificationName(kCI2GoAPITokenReceivedNotification, object: nil)
                    if def.isLoggedIn {
                        session.trackScreen("Glance Placeholder")
                        self.refresh()
                    } else {
                        self.isLoading = false
                        self.updateViews()
                        session.trackScreen("Grance")
                    }
            }
        })
    }

    func refresh() {
        updateViews()
        Build.getList { builds in
            self.build = builds.first
            self.isLoading = false
            self.updateViews()
        }
    }

    override func updateViews() {
        super.updateViews()
        let b = CI2GoUserDefaults.standardUserDefaults().isLoggedIn || isLoading
        placeholderLabel.setHidden(b)
        branchLabel.setHidden(!b)
        buildNumLabel.setHidden(!b)
        repoLabel.setHidden(!b)
        statusGroup.setHidden(!b)
        statusLabel.setHidden(!b)
        commitMessageLabel.setHidden(!b)
        authorLabel.setHidden(!b)
        branchIcon.setHidden(!b)
    }
}
