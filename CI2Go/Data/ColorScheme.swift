//
//  ColorScheme.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreGraphics

struct ColorScheme {
    fileprivate static var configurationCache = [String: Configuration]()

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

    let name: String
    typealias Configuration = [String: [String: Float]]
    
    static let defaultName = "Github"
    static let fileExtension = "itermcolors"
    
    static var names: [String] = {
        let files: [URL] = Bundle.main.urls(forResourcesWithExtension: fileExtension, subdirectory: nil) ?? []
        return files.map { ($0.lastPathComponent as NSString).deletingPathExtension }
            .sorted{$0.compare($1, options: .caseInsensitive) == .orderedAscending }
    }()
    
    static var all: [ColorScheme] = {
        return names.map { ColorScheme($0)! }
    }()
    
    init?(_ name: String) {
        if !ColorScheme.names.contains(name) {
            return nil
        }
        self.name = name
    }
    
    static var `default`: ColorScheme {
        return ColorScheme(defaultName)!
    }
    
    func components(key: String) -> (CGFloat, CGFloat, CGFloat)? {
        if let cmps = configuration[key + " Color"],
            let r = cmps["Red Component"],
            let g = cmps["Green Component"],
            let b = cmps["Blue Component"] {
            return (
                CGFloat(r),
                CGFloat(g),
                CGFloat(b)
            )
        }
        return nil
    }
}

extension ColorScheme: Equatable {
    static func == (lhs: ColorScheme, rhs: ColorScheme) -> Bool {
        return lhs.name.uppercased() == rhs.name.uppercased()
    }
}

extension ColorScheme: Comparable {
    static func < (lhs: ColorScheme, rhs: ColorScheme) -> Bool {
        return lhs.name.uppercased() < rhs.name.uppercased()
    }
}
