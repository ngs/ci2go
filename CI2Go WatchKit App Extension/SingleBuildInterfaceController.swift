//
//  SingleBuildInterfaceController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import WatchConnectivity

class SingleBuildInterfaceController: WKInterfaceController {

    @IBOutlet weak var branchLabel: WKInterfaceLabel!
    @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
    @IBOutlet weak var repoLabel: WKInterfaceLabel!
    @IBOutlet weak var statusGroup: WKInterfaceGroup!
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var commitMessageLabel: WKInterfaceLabel!
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    @IBOutlet weak var branchIcon: WKInterfaceImage!

    var build: Build? {
        didSet { updateViews() }
    }

    func updateViews() {
        let cs = ColorScheme()
        if let build = build, status = build.status {
            self.statusGroup.setBackgroundColor(cs.badgeColor(status: status))
            self.statusLabel.setText(status.humanize)
            self.repoLabel.setText(build.projectPath)
            let numText = "#\(build.number)"
            self.buildNumLabel.setText(numText)
            self.setTitle(numText)
            self.branchLabel.setText(build.branchName)
            self.commitMessageLabel.setText(build.commitSubject)
            self.authorLabel.setText(build.userName)
        } else {
            self.statusGroup.setBackgroundColor(cs.badgeColor(status: nil))
            self.statusLabel.setText("")
            self.repoLabel.setText("")
            self.buildNumLabel.setText("")
            self.branchLabel.setText("")
            self.commitMessageLabel.setText("")
            self.authorLabel.setText("")
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let buildID = context as? String {
            Build.fromCache(buildID) { build in
                self.build = build
            }
        } else {
            Build.fromCache { builds in
                self.build = builds.first
            }
        }
        if let buildId = self.build?.id {
            WCSession.defaultSession().trackEvent(
                category: "build",
                action: "set",
                label: buildId,
                value: 1
            )
        }
    }

    let name = "Build Detail"

    @IBAction func handleRefreshMenuItem() {
        let session = WCSession.defaultSession()
        guard let buildId = self.build?.id else { return }
        session.sendMessage(
            function: .RetryBuild,
            params: [kCI2GoWatchConnectivityBuildIdKey: buildId],
            replyHandler: { res in
                if let buildId = res[kCI2GoWatchConnectivityBuildIdKey] as? String {
                    self.pushControllerWithName(self.name, context: buildId)
                }
        })
    }
}