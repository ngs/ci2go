//
//  SettingsTableView.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

class SettingsTableView: UITableView {
    @IBOutlet weak var apiTokenField: UITextField!

    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = ColorScheme.current.background
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if apiTokenField.isFirstResponder {
            apiTokenField.resignFirstResponder()
        }
        super.touchesBegan(touches, with: event)
    }
}
