//
//  User.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class User: Object, Mappable, Equatable, Comparable {
    dynamic var email: String = ""
    dynamic var login: String = ""
    dynamic var name: String = ""

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
    }

    override class func primaryKey() -> String {
        return "email"
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.email == rhs.email
}

func >(lhs: User, rhs: User) -> Bool {
    return lhs.email > rhs.email
}

func <(lhs: User, rhs: User) -> Bool {
    return lhs.email < rhs.email
}

func >=(lhs: User, rhs: User) -> Bool {
    return lhs.email >= rhs.email
}

func <=(lhs: User, rhs: User) -> Bool {
    return lhs.email <= rhs.email
}