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
        case project = "CI2GoSelectedProject"
        case branch = "CI2GoSelectedBranch"
    }
}
