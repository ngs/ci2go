//
//  BuildTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import DateTools

class BuildTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var buildNumLabel: UILabel!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var branchNameLabel: UILabel!
    @IBOutlet weak var branchIconImageView: UIImageView!
    var build: Build? {
        didSet {
            setNeedsLayout()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.hidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let build = self.build else {
            self.hidden = true
            return
        }
        self.hidden = false
        let status = build.status
        if status != nil {
            statusLabel.text = build.status?.humanize
            statusLabel.hidden = false
        } else {
            statusLabel.hidden = true
        }
        if let branchName = build.branch?.name, shortHash = build.triggeredCommit?.shortHash {
            branchNameLabel.text = "\(branchName) (\(shortHash))"
        } else {
            branchNameLabel.text = build.branch?.name ?? ""
        }
        buildNumLabel.text = "#\(build.number)"
        projectNameLabel.text = build.project?.path ?? ""
        subjectLabel.text = build.triggeredCommit?.subject
        userLabel.text = build.user?.name ?? build.user?.login ?? build.triggeredCommit?.author?.name ?? build.triggeredCommit?.author?.login
        timeLabel.text = build.startedAt?.timeAgoSinceNow() ?? ""
        let scheme = ColorScheme()
        statusLabel.layer.cornerRadius = 3
        statusLabel.layer.masksToBounds = true
        statusLabel.textColor = scheme.backgroundColor()
        statusLabel.backgroundColor = scheme.badgeColor(status: status)
        branchIconImageView.image = UIImage(named: "1081-branch-toolbar")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        branchIconImageView.tintColor = scheme.foregroundColor()
    }
}
