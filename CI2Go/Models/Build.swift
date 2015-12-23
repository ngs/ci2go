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
  @NSManaged public var status: String?
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

  public override class func addPrimaryAttributeWithObjectData(data: AnyObject!) -> NSDictionary? {
    var dic = super.addPrimaryAttributeWithObjectData(data) as! Dictionary<String, AnyObject>?
    if let steps = dic?["steps"] as? [Dictionary<String, AnyObject>] {
      var sec: String? = nil
      , secIndex = 0
      , steps2 = [Dictionary<String, AnyObject>]()
      for step in steps {
        var step2 = step
        , actions2 = [Dictionary<String, AnyObject>]()
        if let actions = step["actions"] as? [Dictionary<String, AnyObject>] {
          for action in actions {
            var action2 = action
            if let type = action["type"] as? String {
              if sec != type {
                secIndex++
                sec = type
              }
              if (type.rangeOfString("^\\d+:", options: NSStringCompareOptions.RegularExpressionSearch) == nil) {
                action2["type"] = "\(secIndex): \(type)"
              }
            }
            actions2.append(action2)
          }
        }
        step2["actions"] = actions2
        steps2.append(step2)
      }
      dic?["steps"] = steps2
    }
    return dic
  }


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
      let decodedName = name.stringByRemovingPercentEncoding!
      let data = [
        "name": decodedName,
        "branchID": "\(project!.urlString!)#\(decodedName)"
      ] as NSDictionary
      branch = Branch.MR_importFromObject(data, inContext: managedObjectContext!) as? Branch
      if project != nil {
        branch?.project = project
      }
    }
    return true
  }

  public var buildParameters: Dictionary<String, AnyObject>? {
    set(value) {
      if let dict = value as NSDictionary? {
        do {
          buildParametersData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())
        } catch {
          buildParametersData = nil
        }
      } else {
        buildParametersData = NSData()
      }
    }
    get {
      if buildParametersData == nil { return nil }
      do {
        let json = try NSJSONSerialization.JSONObjectWithData(buildParametersData!, options: NSJSONReadingOptions.AllowFragments) as? Dictionary<String, AnyObject>
        return json
      } catch {
        return [:]
      }
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
      return retries!.allObjects.sort { (a: AnyObject, b: AnyObject) -> Bool in
        return (a as! Build).number.integerValue < (b as! Build).number.integerValue
        } as! [Build]
    }
  }

  public var apiPath: String? {
    get {
      let path = project?.apiPath
      if(path == nil) {
        return nil
      }
      return "\(path!)/\(number)"
    }
  }
  
}
