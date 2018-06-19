//
//  BuildActionTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

class BuildActionTableViewCell: UITableViewCell {
    @IBOutlet weak var buildStatusBar: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var buildAction: BuildAction? {
        didSet {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //guard let buildAction = buildAction else {
        //    self.contentView.hidden = true
        //    return
        //}
        //let s = ColorScheme.current
        //buildStatusBar.backgroundColor = s.actionColor(status: buildAction.status)
        //let timeMillis: Int
        //if let startedAt = buildAction.startedAt where buildAction.status == .Running {
        //    timeMillis = -Int(startedAt.timeIntervalSinceNow * 1000.0)
        //} else {
        //    timeMillis = buildAction.runTimeMillis
        //}
        //if buildAction.source.utf8.count > 0 {
        //    timeLabel.text = "\(buildAction.source)\n\(timeMillis.timeFormatted)"
        //} else {
        //    timeLabel.text = timeMillis.timeFormatted
        //}
        //if buildAction.isParallel {
        //
        //}
        //let pcnt = buildAction.isParallel ? " (\(buildAction.nodeIndex))" : ""
        //let cmdprefix = buildAction.bashCommand.isEmpty ? "" : "$ "
        //nameLabel.text = cmdprefix + buildAction.name + pcnt
        //self.contentView.hidden = false
    }
    
}
