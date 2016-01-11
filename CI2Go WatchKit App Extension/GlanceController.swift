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

class GlanceController: SingleBuildInterfaceController {
    @IBOutlet weak var placeholderLabel: WKInterfaceLabel!
    override func willActivate() {
        super.willActivate()
        let session = WCSession.defaultSession()
        if CI2GoUserDefaults.standardUserDefaults().isLoggedIn {
            refresh()
            session.trackScreen("Glance")
            placeholderLabel.setHidden(true)
        } else {
            session.trackScreen("Glance Placeholder")
            branchLabel.setHidden(true)
            buildNumLabel.setHidden(true)
            repoLabel.setHidden(true)
            statusGroup.setHidden(true)
            statusLabel.setHidden(true)
            commitMessageLabel.setHidden(true)
            authorLabel.setHidden(true)
            branchIcon.setHidden(true)
        }
    }

    func refresh() {
        Build.requestList { builds in
            self.build = builds.first
        }
    }
}
