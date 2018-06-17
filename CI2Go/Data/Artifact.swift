//
//  Artifact.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Artifact: Decodable {
    let path: String
    let prettyPath: String
    let nodeIndex: Int
    let URL: URL

    enum CodingKeys: String, CodingKey {
        case path
        case prettyPath = "pretty_path"
        case nodeIndex = "node_index"
        case URL = "url"
    }
}
