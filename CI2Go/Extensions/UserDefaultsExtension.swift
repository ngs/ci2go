//
//  UserDefaultsExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case colorScheme = "CI2GoColorScheme"
        case branch = "CI2GoSelectedBranch2"
        case project = "CI2GoSelectedProject2"
    }

    // MARK: -

    func removeObject(forKey defaultKey: Key) {
        removeObject(forKey: defaultKey.rawValue)
    }

    func set(_ value: Any?, forKey defaultKey: Key) {
        set(value, forKey: defaultKey.rawValue)
    }

    func string(forKey defaultKey: Key) -> String? {
        return string(forKey: defaultKey.rawValue)
    }

    func dictionary(forKey defaultKey: Key) -> [String: Any]? {
        return dictionary(forKey: defaultKey.rawValue)
    }

    // MARK: -

    var colorScheme: ColorScheme {
        // swiftlint:disable:next implicit_getter
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
        // swiftlint:disable:next implicit_getter
        get {
            guard
                let dictionary = dictionary(forKey: .branch),
                let branch = Branch(dictionary: dictionary)
                else { return nil }
            return branch
        }

        set(value) {
            removeObject(forKey: .project)
            set(value?.dictionary, forKey: .branch)
        }
    }

    var project: Project? {
        // swiftlint:disable:next implicit_getter
        get {
            guard
                let dictionary = dictionary(forKey: .project) as? [String: String],
                let project = Project(dictionary: dictionary)
                else { return nil }
            return project
        }

        set(value) {
            removeObject(forKey: .branch)
            set(value?.dictionary, forKey: .project)
        }
    }
}
