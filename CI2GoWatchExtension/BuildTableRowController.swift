//
//  BuildTableRowController.swift
//  CI2GoWatchExtension
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation

class BuildTableRowController: NSObject {
    @IBOutlet weak var branchLabel: WKInterfaceLabel!
    @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
    @IBOutlet weak var repoLabel: WKInterfaceLabel!
    @IBOutlet weak var statusColorBar: WKInterfaceGroup!
    @IBOutlet weak var branchIcon: WKInterfaceImage!
    @IBOutlet weak var tagIcon: WKInterfaceImage!
    var build: Build? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let build = build else { return }
        statusColorBar.setBackgroundColor(build.status.color)
        repoLabel.setText(build.project.path)
        buildNumLabel.setText("#\(build.number)")
        tagIcon.setHidden(true)
        branchIcon.setHidden(true)
        if let vcsTag = build.vcsTag {
            tagIcon.setHidden(false)
            branchLabel.setText(vcsTag)
        } else if let branchName = build.branch?.name {
            branchIcon.setHidden(false)
            branchLabel.setText(branchName)
        }
    }
}
