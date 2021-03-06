//
//  BuildInterfaceController.swift
//  CI2GoWatchExtension
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class BuildInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var branchLabel: WKInterfaceLabel!
    @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
    @IBOutlet weak var repoLabel: WKInterfaceLabel!
    @IBOutlet weak var statusGroup: WKInterfaceGroup!
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var commitMessageLabel: WKInterfaceLabel!
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    @IBOutlet weak var branchIcon: WKInterfaceImage!
    @IBOutlet weak var tagIcon: WKInterfaceImage!
    @IBOutlet weak var timeLabel: WKInterfaceLabel!

    var build: Build? {
        didSet {
            guard let build = build else { return }
            statusGroup.setBackgroundColor(build.status.color)
            statusLabel.setText(build.status.humanize)
            repoLabel.setText(build.project.path)
            let numText = "#\(build.number)"
            buildNumLabel.setText(numText)
            setTitle(numText)
            branchIcon.setHidden(true)
            tagIcon.setHidden(true)
            if let vcsTag = build.vcsTag {
                tagIcon.setHidden(false)
                branchLabel.setText(vcsTag)
            } else if let branchName = build.branch?.name {
                branchIcon.setHidden(false)
                branchLabel.setText(branchName)
            }
            commitMessageLabel.setText(build.body)
            authorLabel.setText(build.user?.name ?? build.committerName)
            timeLabel.setText(build.timestamp?.timeAgoSinceNow)
            clearAllMenuItems()
            addMenuItem(with: .repeat, title: "Retry", action: #selector(retryBuild))
            if build.status == .running || build.status == .scheduled {
                addMenuItem(with: .decline, title: "Cancel", action: #selector(cancelBuild))
            }
        }
    }

    override func willActivate() {
        super.willActivate()
        WKExtension.shared().isFrontmostTimeoutExtended = true
        activateWCSession()
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        let userInfo = UserInfo(userInfo)
        userInfo.persist()
    }

    override func awake(withContext context: Any?) {
        self.build = context as? Build
    }

    @objc func retryBuild() {
        guard let build = build else { return }
        URLSession.shared.dataTask(endpoint: .retry(build: build)) { [weak self] (build, _, _, _) in
            guard let build = build else { return }
            DispatchQueue.main.async {
                self?.build = build
            }
        }.resume()
    }

    @objc func cancelBuild() {
        guard let build = build else { return }
        URLSession.shared.dataTask(endpoint: .cancel(build: build)) { [weak self] (build, _, _, _) in
            guard let build = build else { return }
            DispatchQueue.main.async {
                self?.build = build
            }
            }.resume()
    }
}
