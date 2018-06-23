//
//  WCSessionDelegate.swift
//  CI2GoWatchExtension
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import WatchConnectivity
import KeychainAccess

protocol SessionActivationResultDelegate {
    func session(_ sesion: WCSession, didReceiveActivationResult data: (String?, ColorScheme, Project?, Branch?) )
}

extension WCSessionDelegate where Self: SessionActivationResultDelegate {

    func session(_ session: WCSession, didReceiveFunction fn: WatchConnectivityFunction) {
        switch fn {
        case let .activationResult(token, colorScheme, project, branch):
            let d = UserDefaults.shared
            d.colorScheme = colorScheme
            d.project = project
            d.branch = branch
            Keychain.shared.token = token
            self.session(session, didReceiveActivationResult: (token, colorScheme, project, branch))
            break
        default:
            return
        }
    }
}
