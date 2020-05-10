//
//  CustomTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if accessibilityIdentifier?.isEmpty ?? true {
            accessibilityIdentifier = type(of: self).identifier
            isAccessibilityElement = true
        }
    }
}
