//
//  Build.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class Build: CI2GoManagedObject {

  @NSManaged public var authorDate: NSDate
  @NSManaged public var buildParametersData: NSData?
  @NSManaged public var compareURLString: String?
  @NSManaged public var buildID: String?
  @NSManaged public var urlString: String?
  @NSManaged public var dontBuild: String?
  @NSManaged public var isCanceled: NSNumber
  @NSManaged public var isInfrastructureFail: NSNumber
  @NSManaged public var isOpenSource: NSNumber
  @NSManaged public var isTimedout: NSNumber
  @NSManaged public var lifecycle: String?
  @NSManaged public var number: NSNumber
  @NSManaged public var parallelCount: NSNumber
  @NSManaged public var queuedAt: NSDate?
  @NSManaged public var startedAt: NSDate?
  @NSManaged public var status: String
  @NSManaged public var stoppedAt: NSDate?
  @NSManaged public var timeMillis: NSNumber?
  @NSManaged public var why: String?
  @NSManaged public var branch: Branch?
  @NSManaged public var commits: NSSet?
  @NSManaged public var nodes: NSSet?
  @NSManaged public var project: Project?
  @NSManaged public var retries: NSSet?
  @NSManaged public var retryOf: Build?
  @NSManaged public var steps: NSSet?
  @NSManaged public var triggeredCommit: Commit?
  @NSManaged public var user: User?

  public func importUser(json: NSDictionary!) -> Bool {
    if let userJSON = json["user"] as? Dictionary<String, AnyObject> {
      user = User.MR_importFromObject(userJSON, inContext: managedObjectContext!) as? User
      return true
    }
    return false
  }

  public func importTriggeredCommit(json: NSDictionary!) -> Bool {
    return true
  }

  public func importRetryOf(json: NSDictionary!) -> Bool {
    if let num = json["retry_of"] as? Int {
      retryOf = Build.MR_findFirstByAttribute("number", withValue: num, inContext: managedObjectContext)
    }
    return true
  }

  public func importRetries(json: NSDictionary!) -> Bool {
    if let nums = json["retries"] as? [Int] {
      let mSet = NSMutableSet()
      for num in nums {
        if let b = Build.MR_findFirstByAttribute("number", withValue: num, inContext: managedObjectContext) {
          mSet.addObject(b)
        }
      }
      retries = mSet.copy() as? NSSet
    }
    return true
  }

  public func importProject(json: NSDictionary!) -> Bool {
    project = Project.MR_importFromObject(json, inContext: managedObjectContext!) as? Project
    return true
  }

  public func importBuildParametersData(json: NSDictionary!) -> Bool {
    buildParameters = json as? Dictionary<String, AnyObject>
    return true
  }

  public func importBranch(json: NSDictionary!) -> Bool {
    if project == nil {
      importProject(json)
    }
    if let name = json["branch"] as? String {
      let data = [
        "name": name.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
        "branchID": "\(project!.urlString!)#\(name)"
      ]
      branch = Branch.MR_importFromObject(data, inContext: managedObjectContext!) as? Branch
      if project != nil {
        branch?.project = project
      }
    }
    return true
  }

  public var buildParameters: Dictionary<String, AnyObject>? {
    set(value) {
      var error: NSError? = nil
      if let dict = value as NSDictionary? {
        buildParametersData = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.allZeros, error: &error)
      } else {
        buildParametersData = NSData()
      }
    }
    get {
      if buildParametersData == nil { return nil }
      var error: NSError? = nil
      let json = NSJSONSerialization.JSONObjectWithData(buildParametersData!, options: NSJSONReadingOptions.AllowFragments, error: &error) as? Dictionary<String, AnyObject>
      return json
    }
  }

  public var compareURL: NSURL? {
    get {
      return compareURLString == nil ? nil : NSURL(string: compareURLString!)
    }
  }

  public var URL: NSURL? {
    get {
      return urlString == nil ? nil : NSURL(string: urlString!)
    }
  }

  public override func didImport(data: AnyObject!) {
    if let json = data as? NSDictionary {
      if let rev = json["vcs_revision"] as? String {
        triggeredCommit = Commit.MR_findFirstByAttribute("sha1", withValue: rev, inContext: managedObjectContext)
      }
    }
  }

  public var retriesArray: [Build] {
    get {
      if retries == nil {
        return [Build]()
      }
      return retries!.allObjects.sorted { (a: AnyObject, b: AnyObject) -> Bool in
        return (a as Build).number.integerValue < (b as Build).number.integerValue
        } as [Build]
    }
  }

  public var displayStatus: String {
    get {
      let words = status.componentsSeparatedByString("_")
      var ret = [String]()
      for word in words {
        let firstChar = word.substringToIndex(advance(status.startIndex, 1)).uppercaseString
        let remainingChars = word.substringFromIndex(advance(status.startIndex, 1))
        let w = firstChar + remainingChars
        ret.append(w)
      }
      return " ".join(ret)
    }

  }

  public var apiPath: String? {
    get {
      if(project == nil) {
        return nil
      }
      return "project/\(project!.username!)/\(project!.repositoryName!)/\(number)"
    }

  }
  
}
