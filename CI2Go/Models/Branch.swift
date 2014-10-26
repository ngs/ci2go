//
//  Branch.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class Branch: CI2GoManagedObject {

  @NSManaged public var name: String
  @NSManaged public var builds: NSSet
  @NSManaged public var branchID: NSString
  @NSManaged public var project: Project
  @NSManaged public var pushers: NSSet

  public override class func idFromObjectData(data: AnyObject!) -> String? {
    return nil
  }

}
