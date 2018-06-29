//
//  Hostname.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/29.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

enum Hostname: String {
    case github = "github.com"
    case bitbucket = "bitbucket.org"
    case circleci = "circleci.com"
    case app = "ci2go.app"

    init?(url: URL?) {
        guard let host = url?.host else {
            return nil
        }
        if host == Hostname.app.rawValue && url?.scheme != "ci2go" {
            return nil
        }
        self.init(rawValue: host)
    }

    var isAuthProvider: Bool {
        return self == .github || self == .bitbucket
    }

    var isCircleCI: Bool {
        return self == .circleci
    }
}
