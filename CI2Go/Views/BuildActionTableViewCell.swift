//
//  BuildActionTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BuildActionTableViewCell: UITableViewCell {
  @IBOutlet weak var buildStatusBar: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  private var _buildAction: BuildAction? = nil
  public var buildAction: BuildAction? {
    set(value) {
      _buildAction = value
      setNeedsLayout()
    }
    get {
      return _buildAction
    }
  }

  public override func layoutSubviews() {
    let s = ColorScheme()
    buildStatusBar.backgroundColor = s.actionColor(status: buildAction?.status)
    var timeMillis: NSNumber = 0
    if buildAction?.status == "running" && buildAction?.startedAt != nil {
      timeMillis = NSNumber(double: -(buildAction!.startedAt!.timeIntervalSinceNow * 1000))
    } else {
      timeMillis = buildAction!.runTimeMillis
    }
    if buildAction?.source != nil {
      timeLabel.text = "\(buildAction!.source!)\n\(timeMillis.timeFormatted)"
    } else {
      timeLabel.text = timeMillis.timeFormatted
    }
    let pcnt = buildAction?.isParallel.boolValue == true ? " (\(buildAction!.nodeIndex))" : ""
    let cmdprefix = buildAction?.bashCommand != nil ? "$ " : ""
    nameLabel.text = cmdprefix + buildAction!.name! + pcnt
    super.layoutSubviews()
  }

}
