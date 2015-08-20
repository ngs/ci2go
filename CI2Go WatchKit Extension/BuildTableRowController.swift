//
//  BuildTableRow.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation

public class BuildTableRowController: NSObject {
  @IBOutlet weak var branchLabel: WKInterfaceLabel!
  @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
  @IBOutlet weak var repoLabel: WKInterfaceLabel!
  @IBOutlet weak var statusColorBar: WKInterfaceGroup!
  private var _build: Build? = nil
  public var build: Build? {
    set(value) {
      if _build != value {
        _build = value
        updateViews()
      }
    }
    get { return _build }
  }
  func updateViews() {
    let cs = ColorScheme()
    statusColorBar.setBackgroundColor(cs.badgeColor(status: build?.status))
    repoLabel.setText(build?.project?.path)
    buildNumLabel.setText("#\(build!.number.intValue)")
    branchLabel.setText(build?.branch?.name)
  }
}
