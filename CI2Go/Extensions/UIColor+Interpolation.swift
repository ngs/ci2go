//
//  UIColor+Interpolation.swift
//  Originally created by Kyle Weiner
//  https://github.com/kyleweiner/UIColor-Interpolation
//
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIColor {
    // swiftlint:disable:next large_tuple
    var components: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let components = self.cgColor.components!

        switch components.count == 2 {
        case true : return (r: components[0], g: components[0], b: components[0], a: components[1])
        case false: return (r: components[0], g: components[1], b: components[2], a: components[3])
        }
    }

    func interpolate(to toColor: UIColor, with progress: CGFloat) -> UIColor {
        let fromComponents = components
        let toComponents = toColor.components

        let red = (1 - progress) * fromComponents.r + progress * toComponents.r
        let green = (1 - progress) * fromComponents.g + progress * toComponents.g
        let blue = (1 - progress) * fromComponents.b + progress * toComponents.b
        let alpha = (1 - progress) * fromComponents.a + progress * toComponents.a

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
