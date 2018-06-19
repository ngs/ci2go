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
    var branches: [Branch]
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
        self.branches = []
        if let branches = branches {
            self.branches = branches.keys.map { Branch(self, $0) }
        }
    }

    var dictionary: [String: String] {
        return [
            "name": name,
            "username": username,
            "vcs": vcs.rawValue
        ]
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

    init?(dictionary: [String: String]) {
        guard
            let name = dictionary["name"],
            let username = dictionary["username"],
            let rawVCS = dictionary["vcs"],
            let vcs = VCS(rawValue: rawVCS)
            else {
                return nil
        }
        self.init(vcs: vcs, username: username, name: name)
    }

    var path: String {
        return "\(username)/\(name)"
    }

    var apiPath: String {
        return "/project/\(vcs.rawValue)/\(path)"
    }
}

extension Project: Comparable {
    static func < (lhs: Project, rhs: Project) -> Bool {
        return "\(lhs.username)/\(lhs.name)" < "\(rhs.username)/\(rhs.name)"
    }
}
