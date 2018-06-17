//
//  UserDefaultsExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

fileprivate var _shared: UserDefaults?
fileprivate let suiteName = "group.com.ci2go.ios.Circle"

extension UserDefaults {
    enum Key: String {
        case colorScheme = "CI2GoColorScheme"
        case branch = "CI2GoSelectedBranch2"
    }

    var shared: UserDefaults {
        if let shared = _shared {
            return shared
        }
        let shared = UserDefaults(suiteName: suiteName)!
        _shared = shared
        return shared
    }

    // MARK: -

    func set(_ value: Any?, forKey defaultKey: Key) {
        set(value, forKey: defaultKey.rawValue)
    }

    func string(forKey defaultKey: Key) -> String? {
        return string(forKey: defaultKey.rawValue)
    }

    func dictionary(forKey defaultKey: Key) -> [String : Any]? {
        return dictionary(forKey: defaultKey.rawValue)
    }

    // MARK: -

    var colorScheme: ColorScheme {
        get {
            if let name = string(forKey: .colorScheme) {
                return ColorScheme(name) ?? .default
            }
            return .default
        }

        set(value) {
            set(value.name, forKey: .colorScheme)
        }
    }

    var branch: Branch? {
        get {
            guard
                let dictionary = dictionary(forKey: .branch) as? [String: String],
                let branch = Branch(dictionary: dictionary)
                else { return nil }
            return branch
        }
        set(value) {
            set(value?.dictionary, forKey: .branch)
        }
    }
}
