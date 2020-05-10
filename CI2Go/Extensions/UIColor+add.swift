//
//  UIColor+add.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2020/05/10.
//  Copyright © 2020 LittleApps Inc. All rights reserved.
// https://crunchybagel.com/blend-uicolor-swift-extension/
//

import UIKit

extension UIColor {

    func add(overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0

        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0

        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)

        let red = fgA * fgR + (1 - fgA) * bgR
        let green = fgA * fgG + (1 - fgA) * bgG
        let blue = fgA * fgB + (1 - fgA) * bgB

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

func + (lhs: UIColor, rhs: UIColor) -> UIColor {
    return lhs.add(overlay: rhs)
}
