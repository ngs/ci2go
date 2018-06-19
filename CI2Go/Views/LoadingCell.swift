//
//  LoadingCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/19.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    static let identifier = "LoadingCell"
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicatorView.activityIndicatorViewStyle = ColorScheme.current.activityIndicatorViewStyle
        activityIndicatorView.startAnimating()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicatorView.activityIndicatorViewStyle = ColorScheme.current.activityIndicatorViewStyle
        activityIndicatorView.startAnimating()
    }
}
