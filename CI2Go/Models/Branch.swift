//
//  Branch.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/28/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Branch: Object, Mappable, Comparable {
    dynamic var id = ""
    dynamic var name = "" {
        didSet { updateId() }
    }
    dynamic var project: Project? {
        didSet { updateId() }
    }

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
    }

    func updateId() {
        if let projectPath = project?.apiPath where !name.isEmpty && id.isEmpty {
            self.id = "\(projectPath):\(name)"
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return []
    }

    func dup() -> Branch {
        let dup = Branch()
        dup.id = id
        dup.name = name
        dup.project = project?.dup()
        dup.updateId()
        return dup
    }

    override func isEqual(object: AnyObject?) -> Bool {
        return self.id == (object as? Branch)?.id
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