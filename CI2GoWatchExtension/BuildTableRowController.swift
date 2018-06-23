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
        branchLabel.setText(build.branch?.name ?? "")
    }
}
