//
//  BuildEnums.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/7/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation

extension Build {
    enum Lifecycle: String {
        case Queued = "queued"
        case Scheduled = "scheduled"
        case NotRun = "not_run"
        case NotRunning = "not_running"
        case Running = "running"
        case Finished = "finished"
    }
    enum Status: String {
        case Retried = "retried"
        case Canceled = "canceled"
        case InfrastructureFail = "infrastructure_fail"
        case Timedout = "timedout"
        case NotRun = "not_run"
        case Running = "running"
        case Failed = "failed"
        case Queued = "queued"
        case Scheduled = "scheduled"
        case NotRunning = "not_running"
        case NoTests = "no_tests"
        case Fixed = "fixed"
        case Success = "success"
        var humanize: String {
            return rawValue.humanize
        }
    }
    enum Outcome: String {
        case Canceled = "canceled"
        case InfrastructureFail = "infrastructure_fail"
        case Timedout = "timedout"
        case Failed = "failed"
        case NoTests = "no_tests"
        case Success = "success"
    }
}