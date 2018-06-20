//
//  BuildLog.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct BuildLog: Decodable {
    let message: String
    enum CodingKeys: String, CodingKey {
        case message = "message"
    }
    public init(from decoder: Decoder) throws {
        if
            let values = try? decoder.container(keyedBy: CodingKeys.self),
            let message = try? values.decode(String.self, forKey: .message) {
            self.message = message
            return
        }
        if
            let values = try? decoder.singleValueContainer(),
            let message = try? values.decode(String.self) {
            self.message = message
            return
        }
        message = ""
    }
    
}
