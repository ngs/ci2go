//
//  BuildStep.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper
#if os(iOS)
    import CryptoSwift
#endif

class BuildStep: Object, Mappable, Equatable, Comparable {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var index: Int = 0
    dynamic var build: Build?
    let actions = List<BuildAction>()
    var tempActions = [BuildAction]()

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
        name <- map["name"]
        tempActions <- map["actions"]
        updateId()
    }

    func updateId() {
        #if os(iOS)
            if let buildId = build?.id {
                id = "\(buildId):\(name.md5())"
            }
        #endif
        actions.forEach { $0.updateId() }
    }

    func dup() -> BuildStep {
        let dup = BuildStep()
        dup.id = id
        dup.name = name
        dup.index = index
        dup.build = build?.dup()
        dup.actions.appendContentsOf(actions.map{
            let a = $0.dup()
            a.buildStep = dup
            return a
            })
        return dup
    }

    override class func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["tempActions"]
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