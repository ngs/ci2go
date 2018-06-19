//
//  BuildTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
//import DateTools

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
        self.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let build = self.build else {
            self.isHidden = true
            return
        }
        self.isHidden = false
        statusLabel.text = build.status.humanize
        if
            let branchName = build.branch?.name,
            let rev = build.vcsRevision?.prefix(shortHashLength) {
            branchNameLabel.text = "\(branchName) (\(rev))"
        } else {
            branchNameLabel.text = build.branch?.name ?? ""
        }
        buildNumLabel.text = "#\(build.number)"
        projectNameLabel.text = build.project.path
        subjectLabel.text = build.body
        userLabel.text = build.user?.name ?? build.user?.login
        timeLabel.text = build.timestamp?.timeAgoSinceNow
        let scheme = ColorScheme.current
        statusLabel.layer.cornerRadius = 3
        statusLabel.layer.masksToBounds = true
        statusLabel.textColor = scheme.background
        statusLabel.backgroundColor = build.status.color
        branchIconImageView.tintColor = scheme.foreground
    }
}
