//
//  BuildTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import DateTools

public class BuildTableViewCell: UITableViewCell {

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var subjectLabel: UILabel!
  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var buildNumLabel: UILabel!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var branchNameLabel: UILabel!
  @IBOutlet weak var branchIconImageView: UIImageView!
  public private(set) var build: Build? {
    didSet {
      guard let build = build else { return }
      let status = build.status
      if status != nil {
        statusLabel.text = build.status?.humanize
        statusLabel.hidden = false
      } else {
        statusLabel.hidden = true
      }
      if build.branch != nil && build.triggeredCommit != nil {
        branchNameLabel.text = "\(build.branch!.name!) (\(build.triggeredCommit!.shortHash!))"
      } else {
        branchNameLabel.text = build.branch?.name ?? ""
      }
      buildNumLabel.text = "#\(build.number.intValue)"
      if build.project?.repositoryName != nil && build.project?.username != nil {
        projectNameLabel.text = build.project?.path
      } else {
        projectNameLabel.text = ""
      }
      subjectLabel.text = build.triggeredCommit?.subject
      userLabel.text = build.user?.name
      timeLabel.text = build.startedAt?.timeAgoSinceNow() ?? ""
      setNeedsLayout()
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    let scheme = ColorScheme()
    statusLabel.layer.cornerRadius = 3
    statusLabel.layer.masksToBounds = true
    statusLabel.textColor = scheme.backgroundColor()
    buildNumLabel.sizeToFit()
    statusLabel.backgroundColor = scheme.badgeColor(status: build?.status)
    branchIconImageView.image = UIImage(named: "1081-branch-toolbar")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    branchIconImageView.tintColor = scheme.foregroundColor()
  }
}
