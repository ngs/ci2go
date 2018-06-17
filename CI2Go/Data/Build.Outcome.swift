//
//  Build.Outcome.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension Build {
    enum Outcome: String, Codable {
        case canceled = "canceled"
        case infrastructureFail = "infrastructure_fail"
        case timedout = "timedout"
        case failed = "failed"
        case noTests = "no_tests"
        case success = "success"
        case invalid
        var humanize: String {
            return rawValue.humanize
        }
    }
}
