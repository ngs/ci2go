//
//  WCSessionDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import KeychainAccess
import WatchConnectivity

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let fn = WatchConnectivityFunction(message: message), fn == .activate else { return }
        session.sendActivationResult()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }
}


extension WCSession {
    func sendActivationResult() {
        let d = UserDefaults.shared
        sendActivationResult(project: d.project, branch: d.branch)
    }
    func sendActivationResult(project: Project?, branch: Branch?) {
        let result: WatchConnectivityFunction = .activationResult(
            Keychain.shared.token,
            ColorScheme.current,
            project,
            branch
        )
        sendMessage(result.message, replyHandler: nil, errorHandler: nil)
    }
}
