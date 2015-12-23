//
//  BuildTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import NSDate_TimeAgo

public class BuildTableViewCell: UITableViewCell {

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var subjectLabel: UILabel!
  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var buildNumLabel: UILabel!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var branchNameLabel: UILabel!
  @IBOutlet weak var branchIconImageView: UIImageView!
  private var _build: Build? = nil
  public var build: Build? {
    set(value) {
      _build = value
      if value == nil { return }
      let status = value!.status
      // textLabel.text = value?.number.description
      if status != nil {
        statusLabel.text = value?.status?.humanize
        statusLabel.hidden = false
      } else {
        statusLabel.hidden = true
      }
      if value?.branch != nil && value?.triggeredCommit != nil {
        branchNameLabel.text = "\(value!.branch!.name!) (\(value!.triggeredCommit!.shortHash!))"
      } else {
        branchNameLabel.text = value?.branch?.name
      }
      buildNumLabel.text = "#\(value!.number.intValue)"
      if value?.project?.repositoryName != nil && value?.project?.username != nil {
        projectNameLabel.text = value?.project?.path
      } else {
        projectNameLabel.text = ""
      }
      subjectLabel.text = value?.triggeredCommit?.subject
      userLabel.text = value?.user?.name
      if let timeAgo = value?.startedAt?.timeAgoSimple() {
        timeLabel.text = timeAgo + " ago"
      } else {
        timeLabel.text = ""
      }
      setNeedsLayout()
    }
    get {
      return _build
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
