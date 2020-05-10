//
//  BuildArtifactTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class BuildArtifactTableViewCell: CustomTableViewCell {

    var item: BuildArtifactsViewController.RowItem? = nil {
        didSet {
            textLabel?.text = item?.name
            imageView?.image = item?.icon
            if let inProgress = item?.artifact?.isInProgress, inProgress {
                let accessoryView = UIActivityIndicatorView(style: .medium)
                accessoryView.startAnimating()
                self.accessoryView = accessoryView
            } else if let exists = item?.artifact?.localPath.exists, !exists {
                accessoryView = UIImageView(image: #imageLiteral(resourceName: "cloud-download"))
            } else {
                accessoryView = nil
                accessoryType = .disclosureIndicator
            }
        }
    }
}
