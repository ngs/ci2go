//
//  PusherEvent.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/19.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

// https://github.com/circleci/frontend/blob/c189f3546afe49b64c8ee86d92ff67ed9d2eda78/src-cljs/frontend/pusher.cljs#L95-L104
enum PusherEvent: String {
    case call = "call"
    case newAction = "newAction"
    case updateAction = "updateAction"
    case appendAction = "appendAction"
    case updateObservables = "updateObservables"
    case maybeAddMessages = "maybeAddMessages"
    case fetchTestResults = "fetchTestResults"
}
