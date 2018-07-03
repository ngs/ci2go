//
//  PusherEvent.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/19.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

// https://git.io/fSGRg
enum PusherEvent: String {
    case call
    case newAction
    case updateAction
    case appendAction
    case updateObservables
    case maybeAddMessages
    case fetchTestResults
}
