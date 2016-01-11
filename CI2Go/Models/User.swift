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
    var emails: [String]?

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
        var selectedEmail: String?, email: String?
        login <- map["login"]
        name <- map["name"]
        selectedEmail <- map["selected_email"]
        email <- map["email"]
        emails <- map["all_emails"]
        if let email = email ?? selectedEmail {
            self.email = email
        }
    }

    override class func primaryKey() -> String {
        return "email"
    }

    override static func ignoredProperties() -> [String] {
        return ["emails"]
    }

    func dup() -> User {
        let dup = User()
        dup.email = email
        dup.login = login
        dup.name = name
        return dup
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