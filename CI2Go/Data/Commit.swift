//
//  Commit.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Commit: Decodable {
    let body: String
    let branch: String
    let hash: String
    let subject: String
    let URL: URL

    let committerLogin: String
    let committerName: String
    let committerEmail: String
    let committerDate: Date

    let authorLogin: String
    let authorName: String
    let authorEmail: String
    let authorDate: Date

    enum CodingKeys: String, CodingKey {
        case body
        case branch
        case hash = "commit"
        case subject
        case URL = "commit_url"
        case committerLogin = "committer_login"
        case committerName = "committer_name"
        case committerEmail = "committer_email"
        case committerDate = "committer_date"
        case authorLogin = "author_login"
        case authorName = "author_name"
        case authorEmail = "author_email"
        case authorDate = "author_date"
    }
}
