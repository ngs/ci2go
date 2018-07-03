//
//  SSHInfo.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct SSHInfo: Equatable, Comparable {
    let index: Int
    let url: URL

    static func == (_ lhs: SSHInfo, _ rhs: SSHInfo) -> Bool {
        return lhs.index == rhs.index
    }

    static func < (lhs: SSHInfo, rhs: SSHInfo) -> Bool {
        return lhs.index < rhs.index
    }

    var title: String {
        return "Container \(index)"
    }

    var server: String {
        if url.user == "circleci" {
            return String(url.absoluteString.dropFirst("ssh://circleci@".count))
        }
        return String(url.absoluteString.dropFirst("ssh://".count))
    }
}
