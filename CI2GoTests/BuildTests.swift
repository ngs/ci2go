//
//  BuildTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/2/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import XCTest
import CI2Go

class BuildTests: XCTestCase {

  override func setUp() {
    BuildAction.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    BuildStep.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    Commit.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    User.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    Build.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
  }

  func testImportObject() {
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(Build.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 0, "0 record exist")
    let obj = fixtureData("build") as NSDictionary
    let build = Build.MR_importFromObject(obj)
    
    
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 5, "0 record exist")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 1, "0 record exist")
    XCTAssertEqual(Int(Build.MR_countOfEntities()), 1, "0 record exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 40, "0 record exist")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 60, "0 record exist")
    Build.MR_importFromObject(obj)
    Build.MR_importFromObject(obj)
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 5, "0 record exist")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 1, "0 record exist")
    NSLog("%@", User.findAll())
    XCTAssertEqual(Int(Build.MR_countOfEntities()), 1, "0 record exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 40, "0 record exist")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 60, "0 record exist")
  }


}