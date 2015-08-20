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

  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    if apiTokenField.isFirstResponder() {
      apiTokenField.resignFirstResponder()
    }
    super.touchesBegan(touches as Set<NSObject>, withEvent: event)
  }
}
