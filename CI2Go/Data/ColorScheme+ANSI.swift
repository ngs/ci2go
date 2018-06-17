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
        let h = AMR_ANSIEscapeHelper()
        for i in 0..<8 {
            let color1 = self.color(code: i)
            let color2 = self.color(code: i + 8)
            h.ansiColors[30 + i] = color1
            h.ansiColors[40 + i] = color1
            h.ansiColors[50 + i] = color2
        }
        h.defaultStringColor = foreground
        h.font = UIFont(monotype: 17)
        return h
    }
}
