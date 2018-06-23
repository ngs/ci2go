//
//  BuildAction.Status.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension BuildAction {
    enum Status: String, Codable {
        case success = "success"
        case failed = "failed"
        case canceled = "canceled"
        case timedout = "timedout"
        case running = "running"
    }
}
