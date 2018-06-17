//
//  KeychainExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import KeychainAccess

fileprivate var _sharedKeychain: Keychain?
fileprivate let serviceName = "com.ci2go.circle-token"

extension Keychain {
    static var shared: Keychain {
        if let kc = _sharedKeychain {
            return kc
        }
        let groupID = Bundle.main.object(forInfoDictionaryKey: "SharedAccessGroup") as! String
        let kc = Keychain(service: serviceName, accessGroup: groupID)
        _sharedKeychain = kc
        return kc
    }

    var token: String? {
        get {
            return self["token"]
        }
        set(token) {
            self["token"] = token
        }
    }
}
