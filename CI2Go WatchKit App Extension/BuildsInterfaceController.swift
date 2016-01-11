//
//  BuildsInterfaceController.swift
//  CI2Go WatchKit Extension
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import WatchConnectivity

class BuildsInterfaceController: WKInterfaceController {
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    @IBOutlet weak var placeholderGroup: WKInterfaceGroup!
    let maxBuilds = 20

    override func willActivate() {
        super.willActivate()
        self.refresh()
        self.placeholderGroup.setHidden(true)
        self.interfaceTable.setHidden(false)
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "handleApiTokenUpdate:",
                name: kCI2GoAPITokenReceivedNotification, object: nil)
    }

    override func didDeactivate() {
        super.didDeactivate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func handleApiTokenUpdate(sender: AnyObject? = nil) {
        self.refresh()
        let session = WCSession.defaultSession()
        if CI2GoUserDefaults.standardUserDefaults().isLoggedIn {
            self.placeholderGroup.setHidden(true)
            session.trackScreen("Builds")
        } else {
            self.interfaceTable.setHidden(true)
            session.trackScreen("Builds Placeholder")
        }
    }

    func refresh() {
        Build.requestList { self.updateList($0) }
    }

    func updateList(builds: [Build]) {
        var cnt = builds.count
        if(cnt > maxBuilds) {
            cnt = maxBuilds
        }
        self.interfaceTable.setNumberOfRows(cnt, withRowType: "default")
        for var i = 0; i < cnt; i++ {
            if let row = self.interfaceTable.rowControllerAtIndex(i) as? BuildTableRowController {
                row.build = builds[i]
            }
        }
    }

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if let row = table.rowControllerAtIndex(rowIndex) as? BuildTableRowController
            , build = row.build {
                return build.id
        }
        return nil
    }
    
}
