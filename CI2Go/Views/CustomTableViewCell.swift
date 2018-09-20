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
        setupBackground()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBackground()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.backgroundColor = ColorScheme.current.background
        selectedBackgroundView?.backgroundColor = ColorScheme.current.tableViewCellSelectedBackground
    }

    private func setupBackground() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = ColorScheme.current.background
        self.backgroundView = backgroundView

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = ColorScheme.current.tableViewCellSelectedBackground
        self.selectedBackgroundView = selectedBackgroundView
    }
}
