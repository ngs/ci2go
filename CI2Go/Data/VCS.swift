//
//  VCS.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

enum VCS: String, Codable {
    case github = "github"
    case bitbucket = "bitbucket"

    var host: String {
        switch self {
        case .github:
            return "github.com"
        case .bitbucket:
            return "bitbucket.org"
        }
    }

    var shortName: String {
        switch self {
        case .github:
            return "gh"
        case .bitbucket:
            return "bb"
        }
    }
}
