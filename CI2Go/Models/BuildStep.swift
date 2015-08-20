//
//  BuildStep.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class BuildStep: CI2GoManagedObject {

  @NSManaged public var index: NSNumber
  @NSManaged public var name: String
  @NSManaged public var actions: NSSet?
  @NSManaged public var build: Build
  @NSManaged public var buildStepID: String

  public override class func idFromObjectData(data: AnyObject!) -> String? {
    if let json = data as? NSDictionary {
      if let actions = json["actions"] as? [NSDictionary] {
        if actions.count > 0 {
          let name = json["name"] as! String!
          let startTime = actions[0]["start_time"] as! NSString!
          return "[\(startTime)] \(name)"
        }
      }
    }
    return nil
  }

  public override func shouldImport(data: AnyObject!) -> Bool {
    return BuildStep.idFromObjectData(data) != nil
  }

  public var buildActions: [BuildAction] {
    get {
      if actions == nil {
        return [BuildAction]()
      }
      return actions?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "nodeIndex", ascending: true)]) as! [BuildAction]
    }
  }

  public func importActions(data: NSDictionary!) -> Bool {
    if let actions = data["actions"] as? [NSDictionary] {
      if actions.count > 0 {
        let idx = actions[0]["step"] as! Int
        index = idx
      }
      let mSet = NSMutableSet()
      for actionData in actions {
        let action = BuildAction.MR_importFromObject(actionData, inContext: managedObjectContext!) as! BuildAction
        mSet.addObject(action)
      }
      self.actions = mSet.copy() as? NSSet
    }
    return true
  }

}
