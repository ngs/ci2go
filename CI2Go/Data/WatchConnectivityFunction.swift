//
//  WatchConnectivityFunction.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

enum WatchConnectivityFunction: Equatable {
    case activate
    case activationResult(String?, ColorScheme, Project?, Branch?)
    
    init?(message: [String: Any]) {
        guard let fn = message["fn"] as? String else { return nil }
        switch fn {
        case "activate":
            self = .activate
        case "activationResult":
            let project: Project?
            let branch: Branch?
            let colorScheme: ColorScheme
            if let dict = message["project"] as? [String: String] {
                project = Project(dictionary: dict)
            } else {
                project = nil
            }
            if let dict = message["branch"] as? [String: Any] {
                branch = Branch(dictionary: dict)
            } else {
                branch = nil
            }
            if let name = message["colorScheme"] as? String {
                colorScheme = ColorScheme(name) ?? ColorScheme.default
            } else {
                colorScheme = ColorScheme.default
            }
            let token = message["token"] as? String
            self = .activationResult(token, colorScheme, project, branch)
        default:
            return nil
        }
    }
    
    var message: [String: Any] {
        switch self {
        case let .activationResult(token, colorScheme, project, branch):
            var payload: [String: Any] = ["fn": "activationResult"]
            if let token = token {
                payload["token"] = token
            }
            if let branch = branch {
                payload["branch"] = branch.dictionary
            }
            if let project = project {
                payload["project"] = project.dictionary
            }
            payload["colorScheme"] = colorScheme.name
            return payload
        case .activate:
            return ["fn": "activate"]
        }
    }
}
