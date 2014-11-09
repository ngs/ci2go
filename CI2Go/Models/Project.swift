//
//  Project.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class Project: CI2GoManagedObject {

  @NSManaged public var parallelCount: NSNumber?
  @NSManaged public var repositoryName: String?
  @NSManaged public var username: String?
  @NSManaged public var urlString: String?
  @NSManaged public var branches: NSSet?
  @NSManaged public var builds: Build?
  @NSManaged public var commits: NSSet?
  @NSManaged public var projectID: String?

  public var URL: NSURL? {
    get {
      return urlString == nil ? nil : NSURL(string: urlString!)
    }
  }

}
