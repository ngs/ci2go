//
//  Build.Status.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension Build {
    enum Status: String, Codable {
        case retried = "retried"
        case canceled = "canceled"
        case infrastructureFail = "infrastructure_fail"
        case timedout = "timedout"
        case notRun = "not_run"
        case running = "running"
        case failed = "failed"
        case queued = "queued"
        case scheduled = "scheduled"
        case notRunning = "not_running"
        case noTests = "no_tests"
        case fixed = "fixed"
        case success = "success"
        var humanize: String {
            return rawValue.humanize
        }
    }
}
