//
//  CI2GoUserDefaults.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/27/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation

private var _standardUserDefaults: AnyObject? = nil

public let kCI2GoColorSchemeUserDefaultsKey = "CI2GoColorScheme"
public let kCI2GoCircleCIAPITokenDefaultsKey = "CI2GoColorCircleCIAPIToken"
public let kCI2GoCircleCIUsernameDefaultsKey = "CI2GoColorCircleCIAPIUsername"
public let kCI2GoLogRefreshIntervalDefaultsKey = "CI2GoLogRefreshInterval"
public let kCI2GoAPIRefreshIntervalDefaultsKey = "CI2GoAPIRefreshInterval"
public let kCI2GoSelectedProjectDefaultsKey = "CI2GoSelectedProject"
public let kCI2GoSelectedBranchDefaultsKey = "CI2GoSelectedBranch"
public let kCI2GoBranchChangedNotification = "CI2GoBranchChanged"
public let kCI2GoColorSchemeChangedNotification = "CI2GoColorSchemeChanged"

public class CI2GoUserDefaults: NSObject {

  public func reset() {
    for k in [
      kCI2GoColorSchemeUserDefaultsKey,
      kCI2GoCircleCIAPITokenDefaultsKey,
      kCI2GoLogRefreshIntervalDefaultsKey,
      kCI2GoAPIRefreshIntervalDefaultsKey
      ] {
        userDefaults.removeObjectForKey(k)
    }
  }


  public class func standardUserDefaults() -> CI2GoUserDefaults {
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

  public var colorSchemeName: NSString? {
    set(value) {
      if (value != nil && find(ColorScheme.names(), value! as String) != nil) {
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

  public var circleCIAPIToken: NSString? {
    set(value) {
      if (value != nil) {
        userDefaults.setValue(value, forKey: kCI2GoCircleCIAPITokenDefaultsKey)
      } else {
        userDefaults.removeObjectForKey(kCI2GoCircleCIAPITokenDefaultsKey)
        self.circleCIUsername = nil
      }
      userDefaults.synchronize()
    }
    get {
      return userDefaults.stringForKey(kCI2GoCircleCIAPITokenDefaultsKey)
    }
  }

  public var circleCIUsername: NSString? {
    set(value) {
      if (value != nil) {
        userDefaults.setValue(value, forKey: kCI2GoCircleCIUsernameDefaultsKey)
      } else {
        userDefaults.removeObjectForKey(kCI2GoCircleCIUsernameDefaultsKey)
      }
      userDefaults.synchronize()
    }
    get {
      return userDefaults.stringForKey(kCI2GoCircleCIUsernameDefaultsKey)
    }
  }

  public var isLoggedIn: Bool {
    get { return circleCIAPIToken?.length > 0 && circleCIUsername?.length > 0 }
  }

  public var logRefreshInterval: Double {
    set(value) {
      userDefaults.setDouble(value, forKey: kCI2GoLogRefreshIntervalDefaultsKey)
      userDefaults.synchronize()
    }
    get {
      return userDefaults.doubleForKey(kCI2GoLogRefreshIntervalDefaultsKey)
    }
  }

  public var apiRefreshInterval: Double {
    set(value) {
      userDefaults.setDouble(value, forKey: kCI2GoAPIRefreshIntervalDefaultsKey)
      userDefaults.synchronize()
    }
    get {
      return userDefaults.doubleForKey(kCI2GoAPIRefreshIntervalDefaultsKey)
    }
  }

  public var selectedBranch: Branch? {
    set(value) {
      let branchID = value?.branchID
      userDefaults.setValue(branchID, forKey: kCI2GoSelectedBranchDefaultsKey)
      userDefaults.synchronize()
    }
    get {
      if let branchID = userDefaults.stringForKey(kCI2GoSelectedBranchDefaultsKey) {
        return Branch.MR_findFirstByAttribute("branchID", withValue: branchID)
      }
      return nil
    }
  }

  public var selectedProject: Project? {
    set(value) {
      let projectID = value?.projectID
      userDefaults.setValue(projectID, forKey: kCI2GoSelectedProjectDefaultsKey)
      userDefaults.synchronize()
    }
    get {
      let projectID = userDefaults.stringForKey(kCI2GoSelectedProjectDefaultsKey)
      if projectID?.isEmpty != true {
        return Project.MR_findFirstByAttribute("projectID", withValue: projectID)
      }
      return nil
    }
  }

  public var buildsAPIPath: String {
    if let p = selectedProject {
      return p.apiPath!
    }
    return "recent-builds"
  }

  public var buildsPredicate: NSPredicate? {
    if (selectedBranch != nil) {
      return NSPredicate(format: "branch = %@", selectedBranch!)
    }
    if (selectedProject != nil) {
      return NSPredicate(format: "project = %@", selectedProject!)
    }
    return nil
  }

}
