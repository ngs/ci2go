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
    let name: String?
    let vcs: VCS?
    let id: Int? // swiftlint:disable:this identifier_name
    let pusherID: String?
    let isAdmin: Bool?
    let basicEmailPrefs: String?
    let bitbucketAuthorized: Bool?
    let inBetaProgram: Bool?
    let signInCount: Int?
    let isStudent: Bool?
    let trialEnd: Date?
    let webUIPipelinesOptOut: String?
    let webUIPipelinesFirstOptIn: Bool?
    let numProjectsFollowed: Int?

    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
        case name
        case vcs = "vcs_type"
        case pusherID = "pusher_id"
        case id // swiftlint:disable:this identifier_name
        case isAdmin = "admin"
        case basicEmailPrefs = "basic_email_prefs"
        case bitbucketAuthorized = "bitbucket_authorized"
        case inBetaProgram = "in_beta_program"
        case signInCount = "sign_in_count"
        case isStudent = "student"
        case trialEnd = "trial_end"
        case webUIPipelinesFirstOptIn = "web_ui_pipelines_first_opt_in"
        case webUIPipelinesOptOut = "web_ui_pipelines_optout"
        case numProjectsFollowed = "num_projects_followed"
    }

    var pusherChannelName: String? {
        guard let pusherID = pusherID else { return nil }
        return "private-\(pusherID)"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        login = try values.decode(String.self, forKey: .login)
        avatarURL = try? values.decode(URL.self, forKey: .avatarURL)
        name = try? values.decode(String.self, forKey: .name)
        vcs = try? values.decode(VCS.self, forKey: .vcs)
        pusherID = try? values.decode(String.self, forKey: .pusherID)
        id = try? values.decode(Int.self, forKey: .id)
        isAdmin = try? values.decode(Bool.self, forKey: .isAdmin)
        basicEmailPrefs = try? values.decode(String.self, forKey: .basicEmailPrefs)
        bitbucketAuthorized = try? values.decode(Bool.self, forKey: .bitbucketAuthorized)
        inBetaProgram = try? values.decode(Bool.self, forKey: .inBetaProgram)
        signInCount = try? values.decode(Int.self, forKey: .signInCount)
        isStudent = try? values.decode(Bool.self, forKey: .isStudent)
        trialEnd = try? values.decode(Date.self, forKey: .trialEnd)
        webUIPipelinesFirstOptIn = try? values.decode(Bool.self, forKey: .webUIPipelinesFirstOptIn)
        numProjectsFollowed = try? values.decode(Int.self, forKey: .numProjectsFollowed)
        webUIPipelinesOptOut = try? values.decode(String.self, forKey: .webUIPipelinesOptOut)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.login == rhs.login
    }
}
