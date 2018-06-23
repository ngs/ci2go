//
//  WCSessionDelegate.swift
//  CI2GoWatchExtension
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import WatchConnectivity

extension WCSessionDelegate {
    func requestActivation(_ replyHandler: @escaping ((String?, ColorScheme, Project?, Branch?) -> Void)) {
        WCSession.default.sendMessage(WatchConnectivityFunction.activate.message, replyHandler: { message in
            guard let fn = WatchConnectivityFunction(message: message) else { return }
            switch fn {
            case let .activationResult(token, colorScheme, project, branch):
                replyHandler(token, colorScheme, project, branch)
                break
            default:
                return
            }
        })
    }
}
