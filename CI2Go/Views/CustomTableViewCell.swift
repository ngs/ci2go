//
//  CustomTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        let backgroundView = UIView()
        backgroundView.backgroundColor = ColorScheme.current.background
        self.backgroundView = backgroundView

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = ColorScheme.current.tableViewCellSelectedBackground
        self.selectedBackgroundView = selectedBackgroundView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.backgroundColor = ColorScheme.current.background
        selectedBackgroundView?.backgroundColor = ColorScheme.current.tableViewCellSelectedBackground
    }
}
