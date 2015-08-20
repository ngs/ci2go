//
//  Node.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class Node: CI2GoManagedObject {

  @NSManaged public var imageID: String
  @NSManaged public var port: NSNumber
  @NSManaged public var publicIPAddress: String
  @NSManaged public var sshEnabled: NSNumber
  @NSManaged public var username: String
  @NSManaged public var nodeID: String
  @NSManaged public var builds: NSSet

  public override class func idFromObjectData(data: AnyObject!) -> String? {
    if let json = data as? NSDictionary {
      let username = json["username"] as? NSString
      let ipAddress = json["public_ip_addr"] as? NSString
      let port = json["port"] as? NSNumber
      let imageID = json["image_id"] as? NSString
      if username != nil && ipAddress != nil && port != nil && imageID != nil {
        return "\(username!)@\(ipAddress!):\(port!)/\(imageID!)"
      }
    }
    return nil
  }

}
