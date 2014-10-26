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
  @NSManaged public var buildParameters: String
  @NSManaged public var compareURLString: String
  @NSManaged public var isCanceled: NSNumber
  @NSManaged public var isInrastructureFail: NSNumber
  @NSManaged public var isOpenSource: NSNumber
  @NSManaged public var isTimedout: NSNumber
  @NSManaged public var lifecycle: String
  @NSManaged public var number: NSNumber
  @NSManaged public var parallelCount: NSNumber
  @NSManaged public var queuedAt: NSDate
  @NSManaged public var startedAt: NSDate
  @NSManaged public var status: String
  @NSManaged public var stoppedAt: NSDate
  @NSManaged public var timeMillis: NSNumber
  @NSManaged public var why: String
  @NSManaged public var branch: Branch
  @NSManaged public var commits: NSSet
  @NSManaged public var nodes: NSSet
  @NSManaged public var project: Project
  @NSManaged public var retries: NSSet
  @NSManaged public var retryOf: Build
  @NSManaged public var steps: NSSet
  @NSManaged public var triggeredCommit: Commit
  @NSManaged public var user: User
  
  public func importCommits(data: NSDictionary!) -> Bool {
    if let commitDetails = data["all_commit_details"] as? [NSDictionary] {
      let mSet = NSMutableSet()
      if commitDetails.count > 0 {
        for commitData in commitDetails {
          let commit = Commit.MR_importFromObject(commitData)
          mSet.addObject(commit)
        }
      }
      self.commits = mSet.copy() as NSSet
      return true
    }
    return false
  }
  
  public func importSteps(data: NSDictionary!) -> Bool {
    if let steps = data["steps"] as? [NSDictionary] {
      let mSet = NSMutableSet()
      if steps.count > 0 {
        for stepData in steps {
          let step = BuildStep.MR_importFromObject(stepData)
          mSet.addObject(step)
        }
      }
      self.steps = mSet.copy() as NSSet
      return true
    }
    return false
  }
  
  public func importUser(json: NSDictionary!) -> Bool {
    if let email = json["author_email"] as? String {
      let dict = ["email": email] as NSDictionary
      user = User.MR_importFromObject(dict)
      return true
    }
    return false
  }
  
}
