//
//  KeychainWCExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/11/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import KeychainAccess
import WatchConnectivity

extension Keychain {
    func setAndTransfer(token: String) {
        self.token = token
        WCSession.default.transferToken(token: token)
    }
}
