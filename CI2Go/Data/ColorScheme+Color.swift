//
//  ColorScheme+Color.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/19.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension ColorScheme {
    fileprivate static var colorCache: [String: [String: UIColor]] = [:]

    func color(key: String) -> UIColor? {
        if let color = ColorScheme.colorCache[name]?[key] {
            return color
        }
        if
            let (r, g, b) = components(key: key) {
            let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            ColorScheme.colorCache[name] = ColorScheme.colorCache[name] ?? [:]
            ColorScheme.colorCache[name]?[key] = color
            return color
        }
        return nil
    }

    func color(code: Int) -> UIColor? {
        return color(key: NSString(format: "Ansi %d", code) as String)
    }

    var red: UIColor {
        return color(code: 1)!
    }

    var green: UIColor {
        return color(code: 2)!
    }

    var yellow: UIColor {
        return color(code: 3)!
    }

    var blue: UIColor {
        return color(code: 4)!
    }

    var gray: UIColor {
        return foreground.withAlphaComponent(0.4)
    }

    var foreground: UIColor {
        return color(key: "Foreground")!
    }

    var selectedText: UIColor {
        return color(key: "Selected Text")!
    }

    var background: UIColor {
        return color(key: "Background")!
    }

    var selection: UIColor {
        return color(key: "Selection")!
    }

    var bold: UIColor {
        return color(key: "Bold")!
    }

    var placeholder: UIColor {
        return foreground.withAlphaComponent(0.2)
    }

    var groupTableViewBackground: UIColor {
        return background.interpolate(to: bold, with: 0.05)
    }

    var tableViewSeperator: UIColor {
        return UIColor(white: 0.5, alpha: 0.5)
    }

    var tableViewCellSelectedBackground: UIColor {
        return background.interpolate(to: bold, with: 0.5)
    }

    func badge(status: Build.Status) -> UIColor {
        switch status {
        case .success, .fixed:
            return green
        case .running:
            return blue
        case .failed, .timedout, .infrastructureFail, .noTests:
            return red
        default:
            return .gray
        }
    }

    func action(status: BuildAction.Status) -> UIColor {
        switch status {
        case .success:
            return green
        case .running:
            return blue
        case .failed, .timedout:
            return red
        default:
            return .gray
        }
    }

    var isLight: Bool {
        var brightness: CGFloat = 0.0;
        background.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness > 0.5
    }
}
