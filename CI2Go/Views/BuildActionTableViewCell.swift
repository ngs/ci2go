//
//  BuildActionTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

class BuildActionTableViewCell: CustomTableViewCell {
    @IBOutlet weak var buildStatusBar: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var buildAction: BuildAction? {
        didSet {
            guard let buildAction = buildAction else {
                isHidden = true
                return
            }
            timeLabel.text = buildAction.durationFormatted
            nameLabel.text = buildAction.name
            let hasOutput = buildAction.hasOutput || buildAction.status == .running
            accessoryType = hasOutput ? .disclosureIndicator : .none
            selectionStyle = hasOutput ? .default : .none
            isHidden = false
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        buildStatusBar.backgroundColor = buildAction?.status.color
    }

}
