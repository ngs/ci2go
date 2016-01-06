//
//  CI2GoUserDefaults.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/27/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import RealmSwift

private var _standardUserDefaults: AnyObject? = nil

let kCI2GoColorSchemeUserDefaultsKey = "CI2GoColorScheme"
let kCI2GoCircleCIAPITokenDefaultsKey = "CI2GoColorCircleCIAPIToken"
let kCI2GoSchemaVersionDefaultsKey = "CI2GoSchemaVersion"
let kCI2GoSelectedProjectDefaultsKey = "CI2GoSelectedProject"
let kCI2GoSelectedBranchDefaultsKey = "CI2GoSelectedBranch"
let kCI2GoBranchChangedNotification = "CI2GoBranchChanged"
let kCI2GoColorSchemeChangedNotification = "CI2GoColorSchemeChanged"

class CI2GoUserDefaults: NSObject {

    private var testUserDefaults: NSUserDefaults?

    func reset() {
        for k in [
            kCI2GoColorSchemeUserDefaultsKey,
            kCI2GoCircleCIAPITokenDefaultsKey
            ] {
                userDefaults.removeObjectForKey(k)
        }
    }

    lazy var realm: Realm = {
        return try! Realm()
    }()


    class func standardUserDefaults() -> CI2GoUserDefaults {
        if nil == _standardUserDefaults {
            _standardUserDefaults = CI2GoUserDefaults()
        }
        return _standardUserDefaults! as! CI2GoUserDefaults
    }

    private lazy var userDefaults: NSUserDefaults = {
        let ud: NSUserDefaults
        if let _ = NSProcessInfo.processInfo().environment["TEST"] {
            self.testUserDefaults = NSUserDefaults.standardUserDefaults()
            ud = self.testUserDefaults!
        } else {
            ud = NSUserDefaults(suiteName: kCI2GoAppGroupIdentifier)!
        }
        ud.registerDefaults([kCI2GoColorSchemeUserDefaultsKey: "Github"])
        return ud
    }()

    var colorSchemeName: String? {
        set(value) {
            if (value != nil && ColorScheme.names.indexOf((value! as String)) != nil) {
                userDefaults.setValue(value, forKey: kCI2GoColorSchemeUserDefaultsKey)
            } else {
                userDefaults.removeObjectForKey(kCI2GoColorSchemeUserDefaultsKey)
            }
            userDefaults.synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName(kCI2GoColorSchemeChangedNotification, object: nil)
        }
        get {
            return userDefaults.stringForKey(kCI2GoColorSchemeUserDefaultsKey)
        }
    }

    var circleCIAPIToken: String? {
        set(value) {
            if (value != nil) {
                userDefaults.setValue(value, forKey: kCI2GoCircleCIAPITokenDefaultsKey)
            } else {
                userDefaults.removeObjectForKey(kCI2GoCircleCIAPITokenDefaultsKey)
            }
            userDefaults.synchronize()
        }
        get {
            return userDefaults.stringForKey(kCI2GoCircleCIAPITokenDefaultsKey)
        }
    }

    var storedSchemaVersion: UInt64 {
        set(value) {
            userDefaults.setInteger(Int(value), forKey: kCI2GoSchemaVersionDefaultsKey)
            userDefaults.synchronize()
        }
        get {
            return UInt64(userDefaults.integerForKey(kCI2GoSchemaVersionDefaultsKey))
        }
    }

    var isLoggedIn: Bool {
        return circleCIAPIToken?.isEmpty == false
    }

    var selectedBranch: Branch? {
        set(value) {
            let branchID = value?.id
            userDefaults.setValue(branchID, forKey: kCI2GoSelectedBranchDefaultsKey)
            userDefaults.synchronize()
        }
        get {
            if let id = userDefaults.stringForKey(kCI2GoSelectedBranchDefaultsKey) {
                return realm.objects(Branch).filter(NSPredicate(format: "id == %@", id)).first
            }
            return nil
        }
    }

    var selectedProject: Project? {
        set(value) {
            let projectID = value?.id
            userDefaults.setValue(projectID, forKey: kCI2GoSelectedProjectDefaultsKey)
            userDefaults.synchronize()
        }
        get {
            if let id = userDefaults.stringForKey(kCI2GoSelectedProjectDefaultsKey) {
                return realm.objects(Project).filter(NSPredicate(format: "id == %@", id)).first
            }
            return nil
        }
    }

    var buildsAPIPath: String {
        if let p = selectedProject {
            return p.apiPath
        }
        return "recent-builds"
    }
    
}