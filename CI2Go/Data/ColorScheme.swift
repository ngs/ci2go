//
//  ColorScheme.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

struct ColorScheme {
    let name: String
    typealias Configuration = [String: [String: Float]]

    static let defaultName = "Github"
    static let fileExtension = "itermcolors"
    fileprivate static var configurationCache = [String: Configuration]()
    fileprivate static var colorCache: [String: [String: UIColor]] = [:]

    static var names: [String] = {
        let files: [URL] = Bundle.main.urls(forResourcesWithExtension: fileExtension, subdirectory: nil) ?? []
        return files.map { ($0.lastPathComponent as NSString).deletingPathExtension }
            .sorted{$0.compare($1, options: .caseInsensitive) == .orderedAscending }
    }()

    static var `default`: ColorScheme {
        return ColorScheme(defaultName)!
    }

    static var current: ColorScheme {
        return UserDefaults.shared.colorScheme
    }

    func setAsCurrent() {
        UserDefaults.shared.colorScheme = self
    }

    var configuration: Configuration {
        if let config = ColorScheme.configurationCache[name] {
            return config
        }
        let path = Bundle.main.path(forResource: name, ofType: ColorScheme.fileExtension)!
        let dict = NSDictionary(contentsOfFile: path) as! [String: [String: NSNumber]]
        let config: Configuration = dict.mapValues {
            $0.mapValues { $0.floatValue }
        }
        ColorScheme.configurationCache[name] = config
        return config
    }

    init?(_ name: String) {
        if !ColorScheme.names.contains(name) {
            return nil
        }
        self.name = name
    }

    func color(key: String) -> UIColor? {
        if let color = ColorScheme.colorCache[name]?[key] {
            return color
        }
        if
            let cmps = configuration[key + " Color"],
            let r = cmps["Red Component"],
            let g = cmps["Green Component"],
            let b = cmps["Blue Component"] {
            let color = UIColor(
                red: CGFloat(r),
                green: CGFloat(g),
                blue: CGFloat(b),
                alpha: 1.0
            )
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
        case .failed, .timedout, .infrastructureFail:
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
            return yellow
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

