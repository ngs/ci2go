//
//  BuildTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

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
      // textLabel.text = value?.number.description
      if let status = value?.status as String! {
        statusLabel.text = value?.displayStatus
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
      projectNameLabel.text = "\(value!.project!.username!)/\(value!.project!.repositoryName!)"
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
    var color: UIColor?
    let status: String! = build?.status
    switch status {
    case "fixed", "success":
      color = scheme.greenColor()
    case "running":
      color = scheme.blueColor()
    case "failed", "timedout":
      color = scheme.redColor()
    default:
      color = UIColor.grayColor()
    }
    buildNumLabel.sizeToFit()
    statusLabel.backgroundColor = color
    branchIconImageView.image = UIImage(named: "1081-branch-toolbar")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    branchIconImageView.tintColor = scheme.foregroundColor()
  }
}
