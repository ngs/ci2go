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
      var idcomps = [String]()
      if let startTime = json["start_time"] as? String {
        idcomps.append(startTime)
      }
      if let type = json["type"] as? String {
        idcomps.append(type)
      }
      if let name = json["name"] as? String {
        idcomps.append(name)
      }
      if let index = json["index"] as? Int {
        idcomps.append(index.description)
      }
      if let step = json["step"] as? Int {
        idcomps.append(step.description)
      }
      return idcomps.joinWithSeparator(" ")
    }
    return nil
  }

  public var outputURL: NSURL? {
    get {
      return outputURLString == nil ? nil : NSURL(string: outputURLString!)
    }
  }

  public var logFileName: String {
    get {
      let fn = buildActionID.md5
      let si = fn.startIndex
      let ei = si.advancedBy(2)
      return fn.substringToIndex(ei) + "/" + fn.substringFromIndex(ei)
    }
  }

  public var logFile: NSURL {
    return NSFileManager.defaultManager()
      .containerURLForSecurityApplicationGroupIdentifier(kCI2GoAppGroupIdentifier)!
      .URLByAppendingPathComponent("BuildLog", isDirectory: true)
      .URLByAppendingPathComponent(logFileName)
  }

  public var logData: String? {
    get {
      var error: NSError? = nil
      if !NSFileManager.defaultManager().fileExistsAtPath(logFile.absoluteString) {
        return nil
      }
      let m: String?
      do {
        m = try String(contentsOfURL: logFile, encoding: NSUTF8StringEncoding)
      } catch let error1 as NSError {
        error = error1
        m = nil
      }
      if error != nil { NSLog("%@", error!.localizedDescription) }
      return m
    }
    set(value) {
      var error: NSError? = nil
      let m = NSFileManager.defaultManager()
      let dir = logFile.URLByDeletingLastPathComponent!
      if !m.fileExistsAtPath(dir.absoluteString) {
        do {
          try m.createDirectoryAtURL(dir, withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
          error = error1
        }
        if error != nil {
          NSLog("%@", error!.localizedDescription)
          return
        }
      }
      do {
        try value?.writeToURL(logFile, atomically: true, encoding: NSUTF8StringEncoding)
      } catch let error1 as NSError {
        error = error1
      }
      if error != nil {
        NSLog("%@", error!.localizedDescription)
      }
    }
  }

}
