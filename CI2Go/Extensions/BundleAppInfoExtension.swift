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

    var deviceModel: String {
        #if targetEnvironment(macCatalyst)
        return "Mac"
        #else
        return UIDevice.current.model
        #endif
    }

    var deviceSummary: String {
        return """

----
Device: \(deviceModel) / \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
Version: \(appVersion) (\(buildNumber))
"""
.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var submitIssueURL: URL {
        return URL(string: "https://github.com/ngs/ci2go/issues/new?body=\(deviceSummary)")!
    }

    var contactURL: URL {
        let device = deviceModel.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let version = "\(appVersion) (\(buildNumber)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return URL(string: "https://ci2go.app/contact/?device=\(device)&version=\(version))")!
    }
}
