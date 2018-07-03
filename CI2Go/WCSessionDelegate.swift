//
//  WCSessionDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import KeychainAccess
import WatchConnectivity
import Crashlytics

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
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
        let d = UserDefaults.shared
        transferUserInfo(
            token: Keychain.shared.token,
            colorScheme: d.colorScheme,
            project: d.project,
            branch: d.branch
        )
    }

    func transferToken(token: String) {
        let d = UserDefaults.shared
        transferUserInfo(
            token: token,
            colorScheme: d.colorScheme,
            project: d.project,
            branch: d.branch
        )
    }

    func transferSelected(project: Project?, branch: Branch?) {
        transferUserInfo(
            token: Keychain.shared.token,
            colorScheme: UserDefaults.shared.colorScheme,
            project: project,
            branch: branch
        )
    }

    func transferColorScheme(colorScheme: ColorScheme) {
        let d = UserDefaults.shared
        transferUserInfo(
            token: Keychain.shared.token,
            colorScheme: UserDefaults.shared.colorScheme,
            project: d.project,
            branch: d.branch
        )
    }

    fileprivate func transferUserInfo(token: String?, colorScheme: ColorScheme, project: Project?, branch: Branch?) {
        let d = UserDefaults.standard
        var userInfo: [String: Any] = [:]
        if let token = token ?? Keychain.shared.token {
            userInfo["token"] = token
        }
        if let branch = branch ?? d.branch {
            userInfo["branch"] = branch.dictionary
        }
        if let project = project {
            userInfo["project"] = project.dictionary
        }
        userInfo["colorScheme"] = colorScheme.name
        transferUserInfo(userInfo)
        transferCurrentComplicationUserInfo(userInfo)
    }
}
