//
//  Branch.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Branch: EndpointConvertable {
    let name: String
    let project: Project

    var dictionary: [String: Any] {
        return [
            "project": project.dictionary,
            "name": name
        ]
    }
    init(_ project: Project, _ name: String) {
        self.project = project
        self.name = name
    }

    init?(dictionary: [String: Any]) {
        guard
            let name = dictionary["name"] as? String,
            let projectDictionary = dictionary["project"] as? [String: String],
            let project = Project(dictionary: projectDictionary)
            else {
                return nil
        }
        self.name = name
        self.project = project
    }

    var apiPath: String {
        return project.apiPath + "/tree/\(name)"
    }
}

extension Branch: Comparable {
    static func < (lhs: Branch, rhs: Branch) -> Bool {
        if lhs.project == rhs.project {
            return lhs.name.lowercased() < rhs.name.lowercased()
        }
        return lhs.project < rhs.project
    }
}
