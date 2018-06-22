//
//  BuildStep.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct BuildStep: Decodable {
    let actions: [BuildAction]
    let name: String

    enum CodingKeys: String, CodingKey {
        case actions
        case name
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        actions = try values.decode([BuildAction].self, forKey: .actions)
        name = try values.decode(String.self, forKey: .name)
    }

    init(name: String, actions: [BuildAction]) {
        self.name = name
        self.actions = actions
    }

}
