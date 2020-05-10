//
//  KeychainExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import KeychainAccess

private var sharedKeychain: Keychain?
private let serviceName = "com.ci2go.circle-token"

extension Keychain {
    static var shared: Keychain {
        if let keychain = sharedKeychain {
            return keychain
        }
        guard let groupID = Bundle.main.object(forInfoDictionaryKey: "SharedAccessGroup") as? String
            else { fatalError() }
        let keychain = Keychain(service: serviceName, accessGroup: groupID)
        sharedKeychain = keychain
        return keychain
    }

    var token: String? {
        get {
            let defaults = UserDefaults.standard
            if let token = defaults.string(forKey: "circleToken"), defaults.bool(forKey: "FASTLANE_SNAPSHOT") {
                self["token"] = token
                return token
            }
            return self["token"]
        }
        set(token) {
            self["token"] = token
        }
    }
}
