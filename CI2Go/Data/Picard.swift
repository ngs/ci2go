//
//  Picard.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Picard: Decodable {
    let nodes: [BuildNode]

    enum CodingKeys: String, CodingKey {
        case nodes = "ssh_servers"
    }
}
