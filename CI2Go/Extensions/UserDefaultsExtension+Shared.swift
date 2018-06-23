//
//  UserDefaultsExtension+Shared.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

fileprivate var _shared: UserDefaults?
fileprivate let suiteName = "group.com.ci2go.ios.Circle"

extension UserDefaults {
    static var shared: UserDefaults {
        if let shared = _shared {
            return shared
        }
        let shared = UserDefaults(suiteName: suiteName)!
        _shared = shared
        return shared
    }
}
