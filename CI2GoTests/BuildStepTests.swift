//
//  BuildStepTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/8/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import XCTest
import CI2Go

class BuildStepTests: XCTestCase {
  
  override func setUp() {
    BuildAction.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    BuildStep.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
  }
  
  func testImportObject() {
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 0, "0 record exist")
    let obj = ((fixtureData("build") as NSDictionary)["steps"] as NSArray)[1] as NSDictionary
    let step = BuildStep.MR_importFromObject(obj)
    XCTAssertEqual(step.index, 1)
    XCTAssertEqual(step.name, "Start container")
    XCTAssertEqual(step.actions!.count, 2)
    XCTAssertEqual(step.buildActions[0].buildActionID, "2014-10-31T01:40:13.046Z infrastructure (0, 1) - Start container")
    XCTAssertEqual(step.buildActions[1].buildActionID, "2014-10-31T01:40:13.046Z infrastructure (1, 1) - Start container")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 2, "2 records exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 1, "1 record exists")
    BuildStep.MR_importFromObject(obj)
    BuildStep.MR_importFromObject(obj)
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 2, "2 records exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 1, "1 record exists")
  }
  
  func testImportObject2() {
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 0, "0 record exist")
    let obj = ((fixtureData("build") as NSDictionary)["steps"] as NSArray)[20] as NSDictionary
    let step = BuildStep.MR_importFromObject(obj)
    XCTAssertEqual(step.index, 20)
    XCTAssertEqual(step.name, "NODE_ENV=production npm run-script compile")
    XCTAssertEqual(step.actions!.count, 2)
    XCTAssertEqual(step.buildActions[0].buildActionID, "2014-10-31T01:41:04.988Z test (0, 20) - NODE_ENV=production npm run-script compile")
    XCTAssertEqual(step.buildActions[1].buildActionID, "2014-10-31T01:41:04.988Z test (1, 20) - NODE_ENV=production npm run-script compile")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 2, "2 records exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 1, "1 record exists")
    BuildStep.MR_importFromObject(obj)
    BuildStep.MR_importFromObject(obj)
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 2, "2 records exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 1, "1 record exists")
  }
  
}
