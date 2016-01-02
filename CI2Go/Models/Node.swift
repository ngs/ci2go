//
//  Node.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Node: Object, Mappable, Equatable, Comparable {
    dynamic var id = ""
    dynamic var publicIPAddress: String = "" {
        didSet { updateId() }
    }
    dynamic var port: Int = 0 {
        didSet { updateId() }
    }
    dynamic var username = "" {
        didSet { updateId() }
    }
    dynamic var imageId = ""
    dynamic var sshEnabled = false


    override class func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["sshAddress"]
    }

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
        publicIPAddress <- map["public_ip_addr"]
        port <- map["port"]
        username <- map["username"]
        imageId <- map["image_id"]
        sshEnabled <- map["ssh_enabled"]
    }

    var sshAddress: String {
        return "\(username)@\(publicIPAddress):\(port)"
    }

    func updateId() {
        id = sshAddress
    }
}

func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.id == rhs.id
}

func >(lhs: Node, rhs: Node) -> Bool {
    return lhs.id > rhs.id
}

func <(lhs: Node, rhs: Node) -> Bool {
    return lhs.id < rhs.id
}

func >=(lhs: Node, rhs: Node) -> Bool {
    return lhs.id >= rhs.id
}

func <=(lhs: Node, rhs: Node) -> Bool {
    return lhs.id <= rhs.id
}