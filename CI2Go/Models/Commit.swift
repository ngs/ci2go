//
//  Commit.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class Commit: CI2GoManagedObject {
  
  @NSManaged public var body: String?
  @NSManaged public var date: NSDate?
  @NSManaged public var sha1: String?
  @NSManaged public var subject: String?
  @NSManaged public var urlString: String?
  @NSManaged public var author: User?
  @NSManaged public var builds: NSSet?
  @NSManaged public var committer: User?
  @NSManaged public var project: Project?
  @NSManaged public var triggeredBuilds: NSSet?
  
  public func importAuthor(data: AnyObject!) -> Bool {
    if let json = data as? NSDictionary {
      let email = json["author_email"] as? String
      let login = json["author_login"] as? String
      let name = json["author_name"] as? String
      if email != nil && login != nil && name != nil {
        let dict = ["email": email!, "login": login!, "name": name!] as NSDictionary
        author = User.MR_importFromObject(dict)
        return true
      }
    }
    return false
  }
  
  public func importCommitter(data: AnyObject!) -> Bool {
    if let json = data as? NSDictionary {
      let email = json["committer_email"] as? String
      let login = json["committer_login"] as? String
      let name = json["committer_name"] as? String
      if email != nil && login != nil && name != nil {
        let dict = ["email": email!, "login": login!, "name": name!] as NSDictionary
        committer = User.MR_importFromObject(dict)
        return true
      }
    }
    return false
  }
}
