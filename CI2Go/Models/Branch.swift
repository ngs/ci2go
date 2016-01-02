//
//  Branch.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/28/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Branch: Object, Mappable, Equatable, Comparable {
    dynamic var id = ""
    dynamic var name = "" {
        didSet { updateId() }
    }
    dynamic var project: Project? {
        didSet { updateId() }
    }

    let builds = List<Build>()
    let pusher = List<User>()

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
    }

    func updateId() {
        if let projectPath = project?.apiPath where name.utf8.count > 0 {
            self.id = "\(projectPath):\(name)"
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return []
    }
}

func ==(lhs: Branch, rhs: Branch) -> Bool {
    return lhs.id == rhs.id
}

func >(lhs: Branch, rhs: Branch) -> Bool {
    return lhs.id > rhs.id
}

func <(lhs: Branch, rhs: Branch) -> Bool {
    return lhs.id < rhs.id
}

func >=(lhs: Branch, rhs: Branch) -> Bool {
    return lhs.id >= rhs.id
}

func <=(lhs: Branch, rhs: Branch) -> Bool {
    return lhs.id <= rhs.id
}