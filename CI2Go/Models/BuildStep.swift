//
//  BuildStep.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class BuildStep: Object, Mappable, Equatable, Comparable {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var index: Int = 0 {
        didSet { updateId() }
    }
    dynamic var build: Build? {
        didSet { updateId() }
    }
    let actions = List<BuildAction>()

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
        var actions = [BuildAction]()
        name <- map["name"]
        actions <- map["actions"]
        actions.forEach { a in
            a.buildStep = self
            a.sectionIndex = index
            if !self.actions.contains(a) {
                self.actions.append(a)
            }
        }
    }

    func updateId() {
        if let buildId = build?.id {
            id = "\(buildId):\(index)"
        }
        actions.forEach { $0.updateId() }
    }

    override class func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return []
    }
}

func ==(lhs: BuildStep, rhs: BuildStep) -> Bool {
    return lhs.id == rhs.id
}

func >(lhs: BuildStep, rhs: BuildStep) -> Bool {
    return lhs.id > rhs.id
}

func <(lhs: BuildStep, rhs: BuildStep) -> Bool {
    return lhs.id < rhs.id
}

func >=(lhs: BuildStep, rhs: BuildStep) -> Bool {
    return lhs.id >= rhs.id
}

func <=(lhs: BuildStep, rhs: BuildStep) -> Bool {
    return lhs.id <= rhs.id
}