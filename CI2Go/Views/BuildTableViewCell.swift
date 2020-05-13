//
//  BuildTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
//import DateTools

class BuildTableViewCell: CustomTableViewCell {
    @IBOutlet weak var vcsTagImageView: UIImageView!
    @IBOutlet weak var branchImageView: UIImageView!

    @IBOutlet weak var workflowsStackView: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var buildNumLabel: UILabel!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var branchNameLabel: UILabel!
    @IBOutlet weak var commitLabel: UILabel!
    @IBOutlet weak var workflowLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var vcsIconImageView: UIImageView!
    var build: Build? {
        didSet {
            guard let build = build else {
                isHidden = true
                return
            }
            isHidden = false
            statusLabel.text = build.status.humanize
            vcsTagImageView.isHidden = true
            branchImageView.isHidden = true
            commitLabel.isHidden = false
            let commit = String(build.vcsRevision?.prefix(shortHashLength) ?? "")
            if let vcsTag = build.vcsTag {
                branchNameLabel.text = vcsTag
                vcsTagImageView.isHidden = false
            } else if let branchName = build.branch?.name {
                branchNameLabel.text = branchName
                branchImageView.isHidden = false
            } else {
                commitLabel.isHidden = true
                branchNameLabel.text = commit
            }
            commitLabel.text = commit
            workflowLabel.text = build.workflow?.name
            jobLabel.text = build.workflow?.jobName
            workflowsStackView.isHidden = !build.hasWorkflows
            buildNumLabel.text = "#\(build.number)"
            projectNameLabel.text = build.project.path
            subjectLabel.text = build.body
            userLabel.text = build.user?.name ?? build.committerName
            timeLabel.text = build.timestamp?.timeAgoSinceNow
            statusBackgroundView.mask = statusLabel
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        statusBackgroundView.backgroundColor = build?.status.color
        vcsIconImageView.image = build?.project.vcs.icon
        timeLabel.text = build?.timestamp?.timeAgoSinceNow
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isHidden = true
    }

    static func height(for build: Build?) -> CGFloat {
        return build?.hasWorkflows == true ? 95 : 75
    }
}
