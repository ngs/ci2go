//
//  BuildAction.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class BuildAction: CI2GoManagedObject {

  @NSManaged public var bashCommand: String?
  @NSManaged public var command: String?
  @NSManaged public var endedAt: NSDate?
  @NSManaged public var startedAt: NSDate?
  @NSManaged public var exitCode: NSNumber
  @NSManaged public var hasOutput: NSNumber
  @NSManaged public var index: NSNumber
  @NSManaged public var isCanceled: NSNumber
  @NSManaged public var isFailed: NSNumber
  @NSManaged public var isInfrastructureFail: NSNumber
  @NSManaged public var isParallel: NSNumber
  @NSManaged public var isTimedout: NSNumber
  @NSManaged public var isContinue: NSNumber
  @NSManaged public var isTruncated: NSNumber
  @NSManaged public var name: String?
  @NSManaged public var nodeIndex: NSNumber
  @NSManaged public var outputURLString: String?
  @NSManaged public var runTimeMillis: NSNumber
  @NSManaged public var source: String?
  @NSManaged public var status: String?
  @NSManaged public var type: String?
  @NSManaged public var buildStep: BuildStep
  @NSManaged public var buildActionID: String

  public override class func idFromObjectData(data: AnyObject!) -> String? {
    if let json = data as? NSDictionary {
      let command = json["command"] as String!
      let name = json["name"] as String!
      let type = json["type"] as String!
      let startTime = json["start_time"] as String!
      let index = json["index"] as Int
      let step = json["step"] as Int
      return "\(startTime) \(type) (\(index), \(step)) - \(name)"
    }
    return nil
  }

  public var outputURL: NSURL? {
    get {
      return outputURLString == nil ? nil : NSURL(string: outputURLString!)
    }
  }

}
