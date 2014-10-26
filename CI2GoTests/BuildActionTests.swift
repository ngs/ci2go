//
//  BuildActionTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/8/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import XCTest
import CI2Go

class BuildActionTests: XCTestCase {
  
  override func setUp() {
    BuildAction.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
  }
  
  func testImportObject() {
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 0, "0 record exist")
    let obj = ((((fixtureData("build") as NSDictionary)["steps"] as NSArray)[1] as NSDictionary)["actions"] as NSArray)[0] as NSDictionary
    let action = BuildAction.MR_importFromObject(obj)
    XCTAssertFalse(action.isTruncated.boolValue)
    XCTAssertEqual(action.nodeIndex, 0)
    XCTAssertEqual(action.name!, "Start container")
    XCTAssertEqual(action.command!, "Start container")
    XCTAssertTrue(action.isParallel.boolValue)
    XCTAssertFalse(action.isFailed.boolValue)
    XCTAssertFalse(action.isInfrastructureFail.boolValue)
    XCTAssertNil(action.bashCommand)
    XCTAssertEqual(action.status!, "success")
    XCTAssertFalse(action.isTimedout.boolValue)
    XCTAssertFalse(action.isContinue.boolValue)
    XCTAssertEqual(action.endedAt!, NSDate(timeIntervalSince1970: 1414719615.132))
    XCTAssertEqual(action.source!, "config")
    XCTAssertEqual(action.type!, "infrastructure")
    XCTAssertEqual(action.startedAt!, NSDate(timeIntervalSince1970: 1414719613.046))
    XCTAssertEqual(action.exitCode, 0)
    XCTAssertFalse(action.isCanceled.boolValue)
    XCTAssertEqual(action.index, 1)
    XCTAssertEqual(action.runTimeMillis, 2086)
    XCTAssertTrue(action.hasOutput.boolValue)
    XCTAssertEqual(action.outputURL!, NSURL(string: "https://circle-production-action-output.s3.amazonaws.com/path/to/output1.txt")!)
    XCTAssertEqual(action.buildActionID, "2014-10-31T01:40:13.046Z infrastructure (0, 1) - Start container")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 1, "1 record exists")
    BuildAction.MR_importFromObject(obj)
    BuildAction.MR_importFromObject(obj)
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 1, "1 record exists")
  }
  
  func testImportObject2() {
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 0, "0 record exist")
    let obj = ((((fixtureData("build") as NSDictionary)["steps"] as NSArray)[20] as NSDictionary)["actions"] as NSArray)[0] as NSDictionary
    let action = BuildAction.MR_importFromObject(obj)
    XCTAssertFalse(action.isTruncated.boolValue)
    XCTAssertEqual(action.nodeIndex, 0)
    XCTAssertEqual(action.name!, "NODE_ENV=production npm run-script compile")
    XCTAssertEqual(action.command!, "NODE_ENV=production npm run-script compile")
    XCTAssertTrue(action.isParallel.boolValue)
    XCTAssertFalse(action.isFailed.boolValue)
    XCTAssertFalse(action.isInfrastructureFail.boolValue)
    XCTAssertEqual(action.bashCommand!, "NODE_ENV=production npm run-script compile")
    XCTAssertEqual(action.status!, "success")
    XCTAssertFalse(action.isTimedout.boolValue)
    XCTAssertFalse(action.isContinue.boolValue)
    XCTAssertEqual(action.endedAt!, NSDate(timeIntervalSince1970: 1414719687.37))
    XCTAssertEqual(action.source!, "config")
    XCTAssertEqual(action.type!, "test")
    XCTAssertEqual(action.startedAt!, NSDate(timeIntervalSince1970: 1414719664.988))
    XCTAssertEqual(action.exitCode, 0)
    XCTAssertFalse(action.isCanceled.boolValue)
    XCTAssertEqual(action.index, 20)
    XCTAssertEqual(action.runTimeMillis, 22382)
    XCTAssertTrue(action.hasOutput.boolValue)
    XCTAssertEqual(action.outputURL!, NSURL(string: "https://circle-production-action-output.s3.amazonaws.com/path/to/output17.txt")!)
    XCTAssertEqual(action.buildActionID, "2014-10-31T01:41:04.988Z test (0, 20) - NODE_ENV=production npm run-script compile")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 1, "1 record exists")
    BuildAction.MR_importFromObject(obj)
    BuildAction.MR_importFromObject(obj)
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 1, "1 record exists")
  }
  
}
