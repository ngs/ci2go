//
//  UIColor+Mix.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/24/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(betweenColor c1: UIColor, andColor c2: UIColor, percentage p: CGFloat) {
        let p1: CGFloat = 1.0 - p
        let p2: CGFloat = p
        var components = CGColorGetComponents(c1.CGColor)
        let r1 = components[0]
        let g1 = components[1]
        let b1 = components[2]
        let a1 = components[3]
        components = CGColorGetComponents(c2.CGColor)
        let r2 = components[0]
        let g2 = components[1]
        let b2 = components[2]
        let a2 = components[3]
        let red = r1 * p1 + r2 * p2
        let green = g1 * p1 + g2 * p2
        let blue = b1 * p1 + b2 * p2
        let alpha = a1 * p1 + a2 * p2
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
