//
//  AppGlobal.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/27/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation

let kCI2GoAppGroupIdentifier = "group.com.ci2go.ios.Circle"
let kCI2GoCircleCIAPIBaseURL = NSURL(string: "https://circleci.com/api/v1/")
let kCI2GoGATrackingId = "UA-56666052-1"
let kCI2GoPusherAPIKey = "1cf6e0e755e419d2ac9a"
let kCI2GoPusherAuthorizationURL = "https://circleci.com/auth/pusher?circle-token="
let kCI2GoSchemaVersion: UInt64 = 3

func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    if let _ = NSProcessInfo().environment["VERBOSE"] {
        Swift.print(items[0], separator:separator, terminator: terminator)
    }
}