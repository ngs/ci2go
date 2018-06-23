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
    var build: Build?
    var colorScheme: ColorScheme?

    func updateViews() {
        guard
            let build = build,
            let colorScheme = colorScheme
            else { return }
        statusColorBar.setBackgroundColor(colorScheme.badge(status: build.status))
        repoLabel.setText(build.project.path)
        buildNumLabel.setText("#\(build.number)")
        branchLabel.setText(build.branch?.name ?? "")
    }
}
