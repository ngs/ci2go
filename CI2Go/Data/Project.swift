//
//  Project.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Project: Decodable, EndpointConvertable {
    let vcsURL: URL?
    let username: String
    let name: String
    let isFollowing: Bool
    let isOSS: Bool
    let branches: [Branch]
    let vcs: VCS

    enum CodingKeys: String, CodingKey {
        case vcsURL = "vcs_url"
        case username = "username"
        case name = "reponame"
        case isFollowing = "followed"
        case isOSS = "oss"
        case branches
        case vcs = "vcs_type"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        vcsURL = try? values.decode(URL.self, forKey: .vcsURL)
        username = try values.decode(String.self, forKey: .username)
        name = try values.decode(String.self, forKey: .name)
        isFollowing = (try? values.decode(Bool.self, forKey: .isFollowing)) ?? false
        vcs = try values.decode(VCS.self, forKey: .vcs)
        isOSS = (try? values.decode(Bool.self, forKey: .isOSS)) ?? false
        let branches = (try? values.nestedUnkeyedContainer(forKey: .branches)) as? [String: Any]
        self.branches = branches?.keys.map { Branch(name: $0) } ?? []
    }

    init(vcs: VCS, username: String, name: String) {
        vcsURL = URL(string: "https://\(vcs.host)/\(username)/\(name)")!
        isFollowing = false
        isOSS = false
        branches = []
        self.vcs = vcs
        self.username = username
        self.name = name
    }

    var apiPath: String {
        return "/project/\(vcs.rawValue)/\(username)/\(name)"
    }
}
