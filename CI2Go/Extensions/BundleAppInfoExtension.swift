//
//  BundleAppInfoExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2019/04/11.
//  Copyright © 2019 LittleApps Inc. All rights reserved.
//

import Foundation

extension Bundle {
    var appVersion: String {
        guard
            let infoDictionary = infoDictionary,
            let value = infoDictionary["CFBundleShortVersionString"] as? String
            else { fatalError("Could not fetch value of CFBundleShortVersionString") }
        return value
    }

    var buildNumber: String {
        guard
            let infoDictionary = infoDictionary,
            let value = infoDictionary["CFBundleVersion"] as? String
            else { fatalError("Could not fetch value of CFBundleVersion") }
        return value
    }

    var copyright: String {
        guard
            let infoDictionary = infoDictionary,
            let value = infoDictionary["NSHumanReadableCopyright"] as? String
            else { fatalError("Could not fetch value of NSHumanReadableCopyright") }
        return value
    }

    var deviceSummary: String {
        var model = UIDevice.current.model
        #if targetEnvironment(macCatalyst)
        model = "Mac"
        #endif
        return """

----
Device: \(model) / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
Version: \(appVersion) (\(buildNumber))
"""
.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var submitIssueURL: URL {
        return URL(string: "https://github.com/ngs/ci2go/issues/new?body=\(deviceSummary)")!
    }

    var contactURL: URL {
        return URL(string: "mailto:support@ci2go.app?subject=CI2Go%20Support&body=\(deviceSummary)")!
    }
}
