//
//  Project.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/28/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Project: Object, Mappable, Comparable {
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
            id = apiPath
        }
    }

    func mapping(map: Map) {
        var defaultBranchName: String?
        var branches: [Branch]?
        isOpenSource <- map["oss"]
        repositoryName <- map["reponame"]
        parallelCount <- map["parallel"]
        isFollowed <- map["followed"]
        username <- map["username"]
        vcsURLString <- map["vcs_url"]
        defaultBranchName <- map["default_branch"]
        branches <- (map["branches"], ProjectBranchesTransform())
        branches = branches ?? []
        if let defaultBranchName = defaultBranchName {
            let branch = Branch()
            branch.name = defaultBranchName
            branches?.append(branch)
        }
        if let branches = branches {
            branches.forEach { b in
                b.project = self
                if let name = b.name.stringByRemovingPercentEncoding {
                    b.name = name
                }
            }
            self.branches.removeAll()
            self.branches.appendContentsOf(branches)
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["path", "apiPath", "vcsURL"]
    }

    func dup() -> Project {
        let dup = Project()
        dup.parallelCount = parallelCount
        dup.repositoryName = repositoryName
        dup.username = username
        dup.vcsURLString = vcsURLString
        dup.id = id
        dup.isOpenSource = isOpenSource
        dup.isFollowed = isFollowed
        dup.updateId()
        return dup
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return self.id == (object as? Project)?.id
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

func ProjectBranchesTransform() -> TransformOf<[Branch], [String: AnyObject]> {
    return TransformOf<[Branch], [String: AnyObject]>(
        fromJSON: { (value: [String : AnyObject]?) -> [Branch]? in
            guard let keys = value?.keys else { return [] }
            return keys.map { name in
                let b = Branch()
                b.name = name
                return b
            }
        },
        toJSON: { (branches: [Branch]?) -> [String : AnyObject]? in
            return nil // FIXME
        }
    )
}