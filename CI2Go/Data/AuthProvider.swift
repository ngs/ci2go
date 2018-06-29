//
//  AuthProvider.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/29.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

enum AuthProvider: Int {
    case github = 0
    case bitbucket = 1

    var name: String {
        switch self {
        case .github:
            return "GitHub"
        case .bitbucket:
            return "Bitbucket"
        }
    }

    var image: UIImage {
        switch self {
        case .github:
            return #imageLiteral(resourceName: "github")
        case .bitbucket:
            return #imageLiteral(resourceName: "bitbucket")
        }
    }

    var url: URL {
        switch self {
        case .github:
            return URL(string: "https://circleci.com/login?return-to=https://circleci.com/account/api")!
        default:
            return URL(string: "https://circleci.com/bitbucket-login?return-to=https://circleci.com/account/api")!
        }
    }

    var label: String {
        return "Login with \(name)"
    }
}
