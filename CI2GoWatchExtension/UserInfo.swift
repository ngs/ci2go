//
//  UserInfo.swift
//  CI2GoWatchExtension
//
//  Created by Atsushi Nagase on 2018/06/25.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import KeychainAccess

struct UserInfo {
    let project: Project?
    let branch: Branch?
    let colorScheme: ColorScheme
    let token: String?

    init(_ dictionary: [String: Any]) {
        if let dict = dictionary["project"] as? [String: String] {
            project = Project(dictionary: dict)
        } else {
            project = nil
        }
        if let dict = dictionary["branch"] as? [String: Any] {
            branch = Branch(dictionary: dict)
        } else {
            branch = nil
        }
        if let name = dictionary["colorScheme"] as? String {
            colorScheme = ColorScheme(name) ?? ColorScheme.default
        } else {
            colorScheme = ColorScheme.default
        }
        token = dictionary["token"] as? String
    }

    func persist() {
        let d = UserDefaults.shared
        d.project = project
        d.branch = branch
        d.colorScheme = colorScheme
        Keychain.shared.token = token
    }
}
