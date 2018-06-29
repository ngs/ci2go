//
//  SettingsTableView.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

class SettingsTableView: UITableView {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = ColorScheme.current.background
    }
}
