//
//  User.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct User: Decodable {
    let login: String
    let avatarURL: URL?
    let name: String
    let vcs: VCS?
    let id: Int?
    let pusherID: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
        case name
        case vcs = "vcs_type"
        case pusherID = "pusher_id"
        case id
    }

    var pusherChannelName: String? {
        guard let pusherID = pusherID else { return nil }
        return "private-\(pusherID)"
    }
}
