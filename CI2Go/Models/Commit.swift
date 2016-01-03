//
//  Commit.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Commit: Object, Mappable, Equatable, Comparable {
    dynamic var body = ""
    dynamic var commitedAt: NSDate?
    dynamic var authedAt: NSDate?
    dynamic var id = ""
    dynamic var sha1 = "" {
        didSet { updateId() }
    }
    dynamic var subject = ""
    dynamic var urlString: String?
    dynamic var branch: Branch? {
        didSet { updateId() }
    }
    dynamic var author: User?
    dynamic var committer: User?
    dynamic var project: Project? {
        didSet {
            self.branch?.project = project
            self.branch?.updateId()
            updateId()
        }
    }

    var shortHash: String {
        return sha1.substringToIndex(sha1.startIndex.advancedBy(6))
    }

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
        let author = self.author ?? User()
        let committer = self.committer ?? User()
        self.author = author
        self.committer = committer
        var commit: String?, vcsRevision: String?, branchName: String?
        commit <- map["commit"]
        vcsRevision <- map["vcs_revision"]
        commitedAt <- (map["committer_date"], JSONDateTransform())
        authedAt <- (map["author_date"], JSONDateTransform())
        body <- map["body"]
        urlString <- map["commit_url"]
        branchName <- map["branch"]
        author.name <- map["author_name"]
        author.login <- map["author_login"]
        author.email <- map["author_email"]
        committer.name <- map["committer_name"]
        committer.login <- map["committer_login"]
        committer.email <- map["committer_email"]
        subject <- map["subject"]
        sha1 = commit ?? vcsRevision ?? ""
        if let branchName = branchName where !branchName.isEmpty {
            branch = branch ?? Branch()
            branch?.name = branchName
            branch?.project = project
            branch?.updateId()
        }
    }

    func updateId() {
        if let branchId = branch?.id {
            id = "\(branchId):\(sha1)"
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["shortHash"]
    }
}

func ==(lhs: Commit, rhs: Commit) -> Bool {
    return lhs.id == rhs.id
}

func >(lhs: Commit, rhs: Commit) -> Bool {
    return lhs.id > rhs.id
}

func <(lhs: Commit, rhs: Commit) -> Bool {
    return lhs.id < rhs.id
}

func >=(lhs: Commit, rhs: Commit) -> Bool {
    return lhs.id >= rhs.id
}

func <=(lhs: Commit, rhs: Commit) -> Bool {
    return lhs.id <= rhs.id
}
