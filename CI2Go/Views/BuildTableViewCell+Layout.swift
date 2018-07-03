//
//  BuildTableViewCell+Layout.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension BuildTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        let scheme = ColorScheme.current
        let foreground = scheme.foreground
        let background = scheme.background
        tintColor = foreground
        statusLabel.textColor = background
        statusLabel.highlightedTextColor = background
        statusLabel.backgroundColor = build?.status.color
        vcsIconImageView.image = build?.project.vcs.icon
        timeLabel.text = build?.timestamp?.timeAgoSinceNow
    }
}
