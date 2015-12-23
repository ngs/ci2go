//
//  UIColor+Mix.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/24/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIColor {
  class func colorBetweenColor(c1: UIColor, andColor c2: UIColor, percentage p: Float) -> UIColor {
    var p1: Float = 1.0 - p
    var p2: Float = p
    let components: CGFloat = CGColorGetComponents(c1.CGColor)
    var r1: CGFloat = components[0]
    var g1: CGFloat = components[1]
    var b1: CGFloat = components[2]
    var a1: CGFloat = components[3]
    components = CGColorGetComponents(c2.CGColor)
    var r2: CGFloat = components[0]
    var g2: CGFloat = components[1]
    var b2: CGFloat = components[2]
    var a2: CGFloat = components[3]
    return UIColor(red: r1 * p1 + r2 * p2, green: g1 * p1 + g2 * p2, blue: b1 * p1 + b2 * p2, alpha: a1 * p1 + a2 * p2)
  }
}
