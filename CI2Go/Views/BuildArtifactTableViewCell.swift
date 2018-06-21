//
//  BuildArtifactTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class BuildArtifactTableViewCell: CustomTableViewCell {
    static let identifier = "BuildArtifactTableViewCell"

    var item: BuildArtifactsViewController.RowItem? = nil {
        didSet {
            textLabel?.text = item?.name
            imageView?.image = item?.icon
            if let inProgress = item?.artifact?.isInProgress, inProgress {
                let  av = UIActivityIndicatorView(activityIndicatorStyle: ColorScheme.current.activityIndicatorViewStyle)
                av.startAnimating()
                accessoryView = av
            } else if let exists = item?.artifact?.localPath.exists, !exists {
                accessoryView = UIImageView(image: #imageLiteral(resourceName: "cloud-download"))
            } else {
                accessoryView = nil
                accessoryType = .disclosureIndicator
            }
        }
    }
}
