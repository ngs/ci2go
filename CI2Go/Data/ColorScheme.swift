//
//  ColorScheme.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct ColorScheme {
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
    
    static var current: ColorScheme {
        return UserDefaults.shared.colorScheme
    }
    
    func setAsCurrent() {
        UserDefaults.shared.colorScheme = self
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
