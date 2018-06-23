//
//  WCSessionDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import WatchConnectivity
import KeychainAccess

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let fn = WatchConnectivityFunction(message: message), fn == .activate else { return }

        let d = UserDefaults.shared
        let result: WatchConnectivityFunction = .activationResult(
            Keychain.shared.token,
            ColorScheme.current,
            d.project,
            d.branch
        )
        replyHandler(result.message)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }


}
