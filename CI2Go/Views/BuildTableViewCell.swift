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

    static let identifier = "BuildTableViewCell"

    @IBOutlet weak var workflowsStackView: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var buildNumLabel: UILabel!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
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
            branchNameLabel.text = build.branch?.name
            commitLabel.text = String(build.vcsRevision?.prefix(shortHashLength) ?? "")
            workflowLabel.text = build.workflow?.name
            jobLabel.text = build.workflow?.jobName
            workflowsStackView.isHidden = !build.hasWorkflows
            buildNumLabel.text = "#\(build.number)"
            projectNameLabel.text = build.project.path
            subjectLabel.text = build.body
            userLabel.text = build.user?.name ?? build.user?.login
            timeLabel.text = build.timestamp?.timeAgoSinceNow
            setNeedsLayout()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let scheme = ColorScheme.current
        statusLabel.textColor = scheme.background
        statusLabel.backgroundColor = build?.status.color
        vcsIconImageView.image = build?.project.vcs.icon
        timeLabel.text = build?.timestamp?.timeAgoSinceNow
    }
}
