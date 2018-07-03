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
        case success
        case failed
        case canceled
        case timedout
        case running
    }
}
