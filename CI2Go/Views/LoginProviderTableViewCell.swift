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

    var provider: LoginViewController.Provider? = nil {
        didSet {
            textLabel?.text = provider?.label
            imageView?.image = provider?.image
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let fg = ColorScheme.current.foreground
        let bg = ColorScheme.current.background
        let bg2 = ColorScheme.current.tableViewCellSelectedBackground
        textLabel?.textColor = fg
        imageView?.tintColor = fg
        backgroundColor = bg
        backgroundView?.backgroundColor = bg
        selectedBackgroundView?.backgroundColor = bg2
    }
}
