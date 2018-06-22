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
    let step: Int
    let name: String
    let status: Status
    let outputURL: URL?
    let bashCommand: String?
    let hasOutput: Bool
    private let _durationMills: Int
    let startedAt: Date?

    enum CodingKeys: String, CodingKey {
        case index
        case name
        case status
        case outputURL = "output_url"
        case bashCommand = "bash_command"
        case hasOutput = "has_output"
        case _durationMills = "run_time_millis"
        case startedAt = "start_time"
        case step
    }

    var durationMills: Double {
        if let startedAt = startedAt, status == .running {
            return -startedAt.timeIntervalSinceNow * 1000
        }
        return Double(_durationMills)
    }

    var durationFormatted: String {
        let mills = durationMills
        let min = (mills / 60 / 1000).rounded(.towardZero)
        let sec = (mills / 1000).truncatingRemainder(dividingBy: 60).rounded(.towardZero)
        return String(format: "%02d:%02d", Int(min), Int(sec))
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        index = try values.decode(Int.self, forKey: .index)
        name = try values.decode(String.self, forKey: .name)
        status = try values.decode(Status.self, forKey: .status)
        outputURL = try? values.decode(URL.self, forKey: .outputURL)
        bashCommand = try? values.decode(String.self, forKey: .bashCommand)
        hasOutput = (try? values.decode(Bool.self, forKey: .hasOutput)) ?? false
        _durationMills = (try? values.decode(Int.self, forKey: ._durationMills)) ?? 0
        startedAt = try? values.decode(Date.self, forKey: .startedAt)
        step = (try? values.decode(Int.self, forKey: .step)) ?? 0
    }

    init(action: BuildAction, newStatus: Status) {
        index = action.index
        name = action.name
        status = newStatus
        outputURL = action.outputURL
        bashCommand = action.bashCommand
        hasOutput = action.hasOutput
        _durationMills = action._durationMills
        startedAt = action.startedAt
        step = action.step
    }

    init(name: String, index: Int, step: Int, status: Status) {
        self.name = name
        self.index = index
        self.step = step
        self.status = status
        outputURL = nil
        bashCommand = nil
        hasOutput = false
        _durationMills = 0
        startedAt = Date()
    }
}

extension BuildAction: Equatable {
    static func == (lhs: BuildAction, rhs: BuildAction) -> Bool {
        return lhs.index == rhs.index &&
            lhs.step == rhs.step &&
            lhs.status == rhs.status
    }
}


extension BuildAction: Comparable {
    static func < (lhs: BuildAction, rhs: BuildAction) -> Bool {
        return lhs.step < rhs.step
    }
}
