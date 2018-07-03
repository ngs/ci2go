//
//  BuildActionsViewController+Pusher.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import PusherSwift

extension BuildActionsViewController {

    func connectPusher() {
        guard
            let pusher = Pusher.shared,
            let build = build
            else { return }
        pusherChannels = build.pusherChannelNames.map {
            pusher.subscribe($0)
        }
        pusherChannels.forEach { channel in
            channel.bindBuildEvents(
                fetchBuild: { [weak self] (_) -> Build? in
                    if let build = self?.build {
                        return build
                    }
                    self?.loadBuild()
                    return nil
                },
                completionHandler: { [weak self] build in
                    self?.build = build
                    self?.loadBuild()
            })
        }
    }

    func unsubscribePusher() {
        if let pusher = Pusher.shared, !isNavigatingToNext {
            pusherChannels.forEach {
                pusher.unsubscribe($0.name)
            }
        }
    }
}
