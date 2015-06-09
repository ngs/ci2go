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
    Branch.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    Commit.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    User.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    Build.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    Node.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    Project.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
  }

  func testImportObject() {
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(Branch.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(Build.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(Project.MR_countOfEntities()), 0, "0 record exist")

    let obj = fixtureData("build") as! NSDictionary
    let build = Build.MR_importFromObject(obj)
    XCTAssertEqual(build.authorDate, NSDate(timeIntervalSince1970: 1414719610))
    XCTAssertEqual(build.buildParameters! as NSDictionary, ["foo": "bar"])
    XCTAssertEqual(build.compareURL!, NSURL(string: "https://github.com/foo/bar/compare/0432d3e6ac12...863aa2070d2b")!)
    XCTAssertEqual(build.URL!, NSURL(string: "https://circleci.com/gh/foo/bar/1348")!)
    XCTAssertNil(build.dontBuild)
    XCTAssertFalse(build.isCanceled.boolValue)
    XCTAssertFalse(build.isInfrastructureFail.boolValue)
    XCTAssertFalse(build.isOpenSource.boolValue)
    XCTAssertFalse(build.isTimedout.boolValue)
    XCTAssertEqual(build.lifecycle!, "finished")
    XCTAssertEqual(build.number, 1348)
    XCTAssertEqual(build.parallelCount, 2)
    XCTAssertEqual(build.queuedAt!, NSDate(timeIntervalSince1970: 1414719612.209))
    XCTAssertEqual(build.startedAt!, NSDate(timeIntervalSince1970: 1414719612.799))
    XCTAssertEqual(build.status!, "success")
    XCTAssertEqual(build.stoppedAt!, NSDate(timeIntervalSince1970: 1414719714.735))
    XCTAssertEqual(build.timeMillis!, 101936)
    XCTAssertEqual(build.why!, "github")
    XCTAssertEqual(build.branch!.name!, "deployment/qa")
    XCTAssertEqual(build.commits!.count, 5)
    XCTAssertEqual(build.nodes!.count, 2)
    XCTAssertEqual(build.project!.repositoryName!, "myapp")
    XCTAssertEqual(build.project!.username!, "mycompany")
    XCTAssertEqual(build.retries!.count, 0)
    XCTAssertNil(build.retryOf)
    XCTAssertEqual(build.user!.name!, "John Doe")
    XCTAssertEqual(build.triggeredCommit!.sha1!, "863aa2070d2b94e8a9c60513d5580ec9470effb4")
    XCTAssertEqual(Int(Branch.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(Project.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 5, "5 record exist")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(Build.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 40, "40 records exist")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 60, "40 records exist")
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 2, "2 records exist")
    Build.MR_importFromObject(obj)
    Build.MR_importFromObject(obj)
    XCTAssertEqual(Int(Branch.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(Project.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 5, "5 record exist")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(Build.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(BuildStep.MR_countOfEntities()), 40, "40 records exist")
    XCTAssertEqual(Int(BuildAction.MR_countOfEntities()), 60, "40 records exist")
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 2, "2 records exist")
  }

  func testRetries() {
    for n in 101...104 {
      Build.MR_importFromObject([
        "build_num": n,
        "build_url": "https://circleci.com/gh/foo/bar/\(n)"
      ])
    }
    let obj = [
      "build_num": 105,
      "build_url": "https://circleci.com/gh/foo/bar/105",
      "retries": [101, 103],
      "retry_of": 102
    ]
    let b = Build.MR_importFromObject(obj)
    XCTAssertEqual(Int(Build.MR_countOfEntities()), 5, "5 records exist")
    XCTAssertEqual(b.retries!.count, 2)
    XCTAssertEqual(b.retriesArray[0].number, 101)
    XCTAssertEqual(b.retriesArray[1].number, 103)
    XCTAssertEqual(b.retryOf!.number, 102)
  }
  
  
}