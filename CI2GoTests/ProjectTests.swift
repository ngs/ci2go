//
//  ProjectTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import XCTest
import CI2Go

class ProjectTests: XCTestCase {

  override func setUp() {
    Branch.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    Project.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
  }

  func testImportObject() {
    XCTAssertEqual(Int(Branch.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(Project.MR_countOfEntities()), 0, "0 record exist")
    let array = fixtureData("projects") as NSArray
    let projects = Project.MR_importFromArray(array) as [Project]
    let branches = projects[0].branches?.allObjects.sorted({ (a: AnyObject, b: AnyObject) -> Bool in
      return a.name == "master"
    }) as [Branch]
    XCTAssertEqual(projects.count, 2)
    XCTAssertEqual(branches.count, 2)
    XCTAssertEqual(projects[0].repositoryName!, "mongofinil")
    XCTAssertEqual(projects[1].repositoryName!, "mongofinil2")
    XCTAssertEqual(branches[0].name!, "master")
    XCTAssertEqual(branches[1].name!, "develop")
    XCTAssertEqual(Int(Branch.MR_countOfEntities()), 4, "4 records exist")
    XCTAssertEqual(Int(Project.MR_countOfEntities()), 2, "2 records exist")
    Project.MR_importFromArray(array)
    Project.MR_importFromArray(array)
    XCTAssertEqual(Int(Branch.MR_countOfEntities()), 4, "4 records exist")
    XCTAssertEqual(Int(Project.MR_countOfEntities()), 2, "2 records exist")
  }



}
