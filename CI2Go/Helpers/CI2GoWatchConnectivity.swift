//
//  CI2GoWatchConnectivity.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/7/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import WatchConnectivity

let kCI2GoWatchConnectivityFunctionKey = "fn"
let kCI2GoWatchConnectivityBuildIdKey = "buildId"
let kCI2GoWatchConnectivityBuildsKey = "builds"
let kCI2GoWatchConnectivityApiTokenKey = "apiToken"
let kCI2GoWatchConnectivityScreenNameKey = "screenName"
let kCI2GoWatchConnectivityEventCategoryKey = "eventCategory"
let kCI2GoWatchConnectivityEventActionKey = "eventAction"
let kCI2GoWatchConnectivityEventLabelKey = "eventLabel"
let kCI2GoWatchConnectivityEventValueKey = "eventValue"
let kCI2GoWatchConnectivityColorSchemeNameKey = "colorSchemeName"

enum CI2GoWatchConnectivityFunction: String {
    case AppLaunch = "app-launch"
    case RetryBuild = "retry-build"
    case RequestBuilds = "request-builds"
    case TrackScreen = "track-screen"
    case TrackEvent = "track-event"

    func toMessage(var params: [String: AnyObject] = [:]) -> [String: AnyObject] {
        params[kCI2GoWatchConnectivityFunctionKey] = rawValue
        return params
    }
}

extension WCSession {
    func sendMessage(
        function function: CI2GoWatchConnectivityFunction,
        params: [String : AnyObject] = [:],
        replyHandler: (([String : AnyObject]) -> Void)? = nil,
        errorHandler: ((NSError) -> Void)? = nil) {
            self.sendMessage(function.toMessage(params),
                replyHandler: replyHandler,
                errorHandler: errorHandler)
    }

    func trackScreen(screenName: String) {
        self.sendMessage(
            function: .TrackScreen,
            params: [kCI2GoWatchConnectivityScreenNameKey: screenName])
    }

    func trackEvent(category category: String, action: String, label: String, value: Int = 1) {
        self.sendMessage(
            function: .TrackEvent,
            params: [
                kCI2GoWatchConnectivityEventCategoryKey: category,
                kCI2GoWatchConnectivityEventActionKey: action,
                kCI2GoWatchConnectivityEventLabelKey: label,
                kCI2GoWatchConnectivityEventValueKey: value
            ])
    }
}