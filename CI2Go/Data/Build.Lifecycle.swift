//
//  Build.Lifecycle.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension Build {
    enum Lifecycle: String, Codable {
        case queued = "queued"
        case scheduled = "scheduled"
        case notRun = "not_run"
        case notRunning = "not_running"
        case running = "running"
        case finished = "finished"
        var humanize: String {
            return rawValue.humanize
        }
    }
}
