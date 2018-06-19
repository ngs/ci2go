//
//  BuildAction.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct BuildAction: Codable {
    let index: Int
    let name: String
    let status: Status
    let outputURL: URL?
    let bashCommand: String?
    let hasOutput: Bool
    let durationMills: Double
    let startedAt: Date?

    enum CodingKeys: String, CodingKey {
        case index
        case name
        case status
        case outputURL = "output_url"
        case bashCommand = "bash_command"
        case hasOutput = "has_output"
        case durationMills = "run_time_millis"
        case startedAt = "start_time"
    }
}

