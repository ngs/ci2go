//
//  Branch.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Branch {
    let name: String
    let project: Project

    var dictionary: [String: String] {
        return [
            "name": name,
            "projectName": project.name,
            "projectUsername": project.username,
            "projectVCS": project.vcs.rawValue
        ]
    }
    init(_ project: Project, _ name: String) {
        self.project = project
        self.name = name
    }

    init?(dictionary: [String: String]) {
        guard
            let name = dictionary["name"],
            let projectName = dictionary["projectName"],
            let projectUsername = dictionary["projectUsername"],
            let projectVCS = dictionary["projectVCS"],
            let vcs = VCS(rawValue: projectVCS)
            else {
                return nil
        }
        self.name = name
        self.project = Project(vcs: vcs, username: projectUsername, name: projectName)
    }
}

extension Branch: Equatable {
    static func == (lhs: Branch, rhs: Branch) -> Bool {
        return lhs.project == rhs.project && lhs.name == rhs.name
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
