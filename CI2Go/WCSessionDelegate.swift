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
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        session.transferUserInfo()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        session.transferUserInfo()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }
}

extension WCSession {
    func transferUserInfo() {
        let defaults = UserDefaults.shared
        transferUserInfo(
            token: Keychain.shared.token,
            project: defaults.project,
            branch: defaults.branch
        )
    }

    func transferToken(token: String) {
        let defaults = UserDefaults.shared
        transferUserInfo(
            token: token,
            project: defaults.project,
            branch: defaults.branch
        )
    }

    func transferSelected(project: Project?, branch: Branch?) {
        transferUserInfo(
            token: Keychain.shared.token,
            project: project,
            branch: branch
        )
    }

    fileprivate func transferUserInfo(token: String?, project: Project?, branch: Branch?) {
        let defaults = UserDefaults.standard
        var userInfo: [String: Any] = [:]
        if let token = token ?? Keychain.shared.token {
            userInfo["token"] = token
        }
        if let branch = branch ?? defaults.branch {
            userInfo["branch"] = branch.dictionary
        }
        if let project = project {
            userInfo["project"] = project.dictionary
        }
        transferUserInfo(userInfo)
        transferCurrentComplicationUserInfo(userInfo)
    }
}
