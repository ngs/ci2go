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
    
    static var names: [String] = {
        let files: [URL] = Bundle.main.urls(forResourcesWithExtension: fileExtension, subdirectory: nil) ?? []
        return files.map { ($0.lastPathComponent as NSString).deletingPathExtension }
            .sorted{$0.compare($1, options: .caseInsensitive) == .orderedAscending }
    }()
    
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
        if
            let cmps = configuration[key + " Color"],
            let r = cmps["Red Component"],
            let g = cmps["Green Component"],
            let b = cmps["Blue Component"] {
            return UIColor(
                red: CGFloat(r),
                green: CGFloat(g),
                blue: CGFloat(b),
                alpha: 1.0
            )
        }
        return nil
    }
    
    func color(code: Int) -> UIColor? {
        return color(key: NSString(format: "Ansi %d", code) as String)
    }
}

