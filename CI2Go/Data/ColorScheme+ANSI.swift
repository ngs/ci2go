//
//  ColorScheme+ANSI.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension ColorScheme {
    func createANSIEscapeHelper() -> AMR_ANSIEscapeHelper {
        let helper = AMR_ANSIEscapeHelper()
        for index in 0..<8 {
            let color1 = self.color(code: index)
            let color2 = self.color(code: index + 8)
            helper.ansiColors[30 + index] = color1
            helper.ansiColors[40 + index] = color1
            helper.ansiColors[50 + index] = color2
        }
        helper.defaultStringColor = foreground
        helper.font = UIFont(monotype: 12)
        return helper
    }
}
