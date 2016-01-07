//
//  BuildTableRow.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
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
    let cs = ColorScheme()
    statusColorBar.setBackgroundColor(cs.badgeColor(status: build.status))
    repoLabel.setText(build.projectPath)
    buildNumLabel.setText("#\(build.number)")
    branchLabel.setText(build.branchName)
  }
}