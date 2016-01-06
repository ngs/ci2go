//
//  AppGlobal.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/27/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import RealmSwift

let kCI2GoAppGroupIdentifier = "group.com.ci2go.ios.Circle"
let kCI2GoCircleCIAPIBaseURL = NSURL(string: "https://circleci.com/api/v1/")
let kCI2GoGATrackingId = "UA-56666052-1"
let kCI2GoPusherAPIKey = "1cf6e0e755e419d2ac9a"
let kCI2GoPusherAuthorizationURL = "https://circleci.com/auth/pusher?circle-token="
let kCI2GoSchemaVersion: UInt64 = 2

func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    if let _ = NSProcessInfo().environment["VERBOSE"] {
        Swift.print(items[0], separator:separator, terminator: terminator)
    }
}

var realmPath: String {
    let fileURL = NSFileManager.defaultManager()
        .containerURLForSecurityApplicationGroupIdentifier(kCI2GoAppGroupIdentifier)?
        .URLByAppendingPathComponent("ci2go.realm")
    return fileURL!.path!
}

func setupRealm() {
    let env = NSProcessInfo().environment

    var config = Realm.Configuration(schemaVersion: kCI2GoSchemaVersion)
    if let identifier = env["REALM_MEMORY_IDENTIFIER"] {
        config.inMemoryIdentifier = identifier
    } else {
        config.path = realmPath
    }
    let def = CI2GoUserDefaults.standardUserDefaults()
    if def.storedSchemaVersion != kCI2GoSchemaVersion {
        if let path = Realm.Configuration.defaultConfiguration.path {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch {}
        }
        _ = try! Realm()
        def.storedSchemaVersion = kCI2GoSchemaVersion
    }
    Realm.Configuration.defaultConfiguration = config
}