//
//  SettingsFooterView.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class SettingsFooterView: UIView {
    @IBOutlet weak var copyrightLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        let info = Bundle.main.infoDictionary ?? [:]
        let version = info["CFBundleShortVersionString"] as! String
        let buildNum = info["CFBundleVersion"] as! String
        let y = Calendar.current.component(.year, from: Date())
        copyrightLabel.text = "CI2Go \(version) (\(buildNum)) © 2014-\(y) LittleApps Inc."
    }
}
