//
//  Project.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/28/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Project: Object, Mappable, Equatable, Comparable {
    dynamic var parallelCount: Int = 0
    dynamic var repositoryName = "" {
        didSet { updateId() }
    }
    dynamic var username = "" {
        didSet { updateId() }
    }
    dynamic var vcsURLString: String?
    dynamic var id = ""
    dynamic var isOpenSource = false
    dynamic var isFollowed = false
    let branches = List<Branch>()
    let builds = List<Build>()
    let commits = List<Commit>()
    var path: String {
        return "\(username)/\(repositoryName)"
    }
    var apiPath: String {
        return "project/\(path)"
    }
    var vcsURL: NSURL? {
        if let vcsURLString = vcsURLString {
            return NSURL(string: vcsURLString)
        }
        return nil
    }

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func updateId() {
        if username.utf8.count > 0 && repositoryName.utf8.count > 0 {
            id = path
        }
    }

    func mapping(map: Map) {
        var defaultBranchName: String?
        isOpenSource <- map["oss"]
        repositoryName <- map["reponame"]
        parallelCount <- map["parallel"]
        isFollowed <- map["followed"]
        username <- map["username"]
        vcsURLString <- map["vcs_url"]
        defaultBranchName <- map["default_branch"]
        if let defaultBranchName = defaultBranchName {
            let branch = Branch()
            branch.project = self
            branch.name = defaultBranchName
            if !branches.contains(branch) {
                branches.append(branch)
            }
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }
}

func ==(lhs: Project, rhs: Project) -> Bool {
    return lhs.id == rhs.id
}

func >(lhs: Project, rhs: Project) -> Bool {
    return lhs.id > rhs.id
}

func <(lhs: Project, rhs: Project) -> Bool {
    return lhs.id < rhs.id
}

func >=(lhs: Project, rhs: Project) -> Bool {
    return lhs.id >= rhs.id
}

func <=(lhs: Project, rhs: Project) -> Bool {
    return lhs.id <= rhs.id
}
