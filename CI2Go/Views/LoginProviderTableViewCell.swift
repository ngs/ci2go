//
//  LoginProviderTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/29.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class LoginProviderTableViewCell: CustomTableViewCell {
    static let loginCellIdentifier = "LoginProviderTableViewCell"

    var provider: AuthProvider? = nil {
        didSet {
            textLabel?.text = provider?.label
            imageView?.image = provider?.image
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let foreground = ColorScheme.current.foreground
        let background = ColorScheme.current.background
        let background2 = ColorScheme.current.tableViewCellSelectedBackground
        textLabel?.textColor = foreground
        imageView?.tintColor = foreground
        backgroundColor = background
        backgroundView?.backgroundColor = background
        selectedBackgroundView?.backgroundColor = background2
    }
}
