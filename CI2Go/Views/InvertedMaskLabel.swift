//
//  InvertedMaskLabel.swift
//  CI2Go
//  Bollowed from https://stackoverflow.com/a/37669431
//
//  Created by Atsushi Nagase on 2018/07/04.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class InvertedMaskLabel: UILabel {
    override func drawText(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        UIColor.white.setFill()
        UIRectFill(rect)
        context.setBlendMode(.clear)
        super.drawText(in: rect)
        context.restoreGState()
    }
}
