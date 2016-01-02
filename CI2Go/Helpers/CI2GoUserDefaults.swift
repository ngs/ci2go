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
let kCI2GoLogRefreshIntervalDefaultsKey = "CI2GoLogRefreshInterval"
let kCI2GoAPIRefreshIntervalDefaultsKey = "CI2GoAPIRefreshInterval"
let kCI2GoSelectedProjectDefaultsKey = "CI2GoSelectedProject"
let kCI2GoSelectedBranchDefaultsKey = "CI2GoSelectedBranch"
let kCI2GoBranchChangedNotification = "CI2GoBranchChanged"
let kCI2GoColorSchemeChangedNotification = "CI2GoColorSchemeChanged"

class CI2GoUserDefaults: NSObject {

    func reset() {
        for k in [
            kCI2GoColorSchemeUserDefaultsKey,
            kCI2GoCircleCIAPITokenDefaultsKey,
            kCI2GoLogRefreshIntervalDefaultsKey,
            kCI2GoAPIRefreshIntervalDefaultsKey
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

    private var _userDefaults: NSUserDefaults? = nil
    private var userDefaults: NSUserDefaults {
        if nil == _userDefaults {
            _userDefaults = NSUserDefaults(suiteName: kCI2GoAppGroupIdentifier)
            _userDefaults?.registerDefaults([
                kCI2GoColorSchemeUserDefaultsKey: "Github",
                kCI2GoLogRefreshIntervalDefaultsKey: 1.0,
                kCI2GoAPIRefreshIntervalDefaultsKey: 5.0
                ])
        }
        return _userDefaults!
    }

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

    var isLoggedIn: Bool {
        get { return circleCIAPIToken?.utf8.count > 0 }
    }

    var logRefreshInterval: Double {
        set(value) {
            userDefaults.setDouble(value, forKey: kCI2GoLogRefreshIntervalDefaultsKey)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.doubleForKey(kCI2GoLogRefreshIntervalDefaultsKey)
        }
    }

    var apiRefreshInterval: Double {
        set(value) {
            userDefaults.setDouble(value, forKey: kCI2GoAPIRefreshIntervalDefaultsKey)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.doubleForKey(kCI2GoAPIRefreshIntervalDefaultsKey)
        }
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