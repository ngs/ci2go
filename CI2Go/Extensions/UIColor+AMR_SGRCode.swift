//
//  UIColor+AMR_SGRCode.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2020/05/10.
//  Copyright © 2020 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIColor {
    static var systemMagenta: UIColor {
        return UIColor.systemPink
    }

    static var systemCyan: UIColor {
        return UIColor.systemTeal
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    static func from(sgrCode: AMR_SGRCode) -> UIColor {
        switch sgrCode {
        case AMR_SGRCodeFgBlack:
            return .label
        case AMR_SGRCodeFgRed:
            return .systemRed
        case AMR_SGRCodeFgGreen:
            return .systemGreen
        case AMR_SGRCodeFgYellow:
            return .systemOrange
        case AMR_SGRCodeFgBlue:
            return .systemBlue
        case AMR_SGRCodeFgMagenta:
            return .systemMagenta
        case AMR_SGRCodeFgCyan:
            return .systemCyan
        case AMR_SGRCodeFgWhite:
            return .systemBackground
        case AMR_SGRCodeFgReset:
            return .label

        case AMR_SGRCodeBgBlack:
            return .label
        case AMR_SGRCodeBgRed:
            return .systemRed
        case AMR_SGRCodeBgGreen:
            return .systemGreen
        case AMR_SGRCodeBgYellow:
            return .systemOrange
        case AMR_SGRCodeBgBlue:
            return .systemBlue
        case AMR_SGRCodeBgMagenta:
            return .systemMagenta
        case AMR_SGRCodeBgCyan:
            return .systemCyan
        case AMR_SGRCodeBgWhite:
            return .systemBackground
        case AMR_SGRCodeBgReset:
            return .systemBackground

        case AMR_SGRCodeFgBrightBlack:
            return .label
        case AMR_SGRCodeFgBrightRed:
            return .systemRed
        case AMR_SGRCodeFgBrightGreen:
            return .systemGreen
        case AMR_SGRCodeFgBrightYellow:
            return .systemOrange
        case AMR_SGRCodeFgBrightBlue:
            return .systemBlue
        case AMR_SGRCodeFgBrightMagenta:
            return .systemMagenta
        case AMR_SGRCodeFgBrightCyan:
            return .systemCyan
        case AMR_SGRCodeFgBrightWhite:
            return .label

        case AMR_SGRCodeBgBrightBlack:
            return .label
        case AMR_SGRCodeBgBrightRed:
            return .systemRed
        case AMR_SGRCodeBgBrightGreen:
            return .systemGreen
        case AMR_SGRCodeBgBrightYellow:
            return .systemOrange
        case AMR_SGRCodeBgBrightBlue:
            return .systemBlue
        case AMR_SGRCodeBgBrightMagenta:
            return .systemMagenta
        case AMR_SGRCodeBgBrightCyan:
            return .systemCyan
        case AMR_SGRCodeBgBrightWhite:
            return .systemBackground
        default:
            return .darkText
        }
    }

}
