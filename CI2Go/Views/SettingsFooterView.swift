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

    static var height: CGFloat {
        return 300
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        copyrightLabel.text = "CI2Go \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))\n\(Bundle.main.copyright)"
    }
}
