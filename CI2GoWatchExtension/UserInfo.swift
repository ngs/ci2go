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
        token = dictionary["token"] as? String
    }

    func persist() {
        let defaults = UserDefaults.shared
        defaults.project = project
        defaults.branch = branch
        Keychain.shared.token = token
    }
}
