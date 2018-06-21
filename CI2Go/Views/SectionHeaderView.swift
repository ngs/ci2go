//
//  BuildActionSectionHeaderView.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {
    @IBOutlet weak var textLabel: UILabel!

    static let identifier = "SectionHeaderView"

    var text: String? = nil {
        didSet {
            textLabel.text = text
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel.text = text
    }
}
