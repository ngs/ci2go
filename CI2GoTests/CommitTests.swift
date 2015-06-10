//
//  CommitTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/2/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import XCTest
import CI2Go

class CommitTests: XCTestCase {

  override func setUp() {
    Commit.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    User.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
  }

  func testImportObject() {
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 0, "0 record exist")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 0, "0 record exist")
    let obj = (((fixtureData("build") as! NSDictionary)["all_commit_details"] as! NSArray)[1] as! NSDictionary)
    let commit = Commit.MR_importFromObject(obj)
    XCTAssertEqual(commit.body!, "不要な設定項目の削除")
    XCTAssertEqual(commit.date!, NSDate(timeIntervalSince1970: 1414006582))
    XCTAssertEqual(commit.sha1!, "67b75ca7c70c097363c8998c36fa53910dfc941d")
    XCTAssertEqual(commit.subject!, "Merge pull request #360 from mycompany/remove-unused-option")
    XCTAssertEqual(commit.urlString!, "https://github.com/foo/bar/commit/67b75ca7c70c097363c8998c36fa53910dfc941d")
    XCTAssertEqual(commit.author!.email!, "john.doe@gmail.com")
    XCTAssertEqual(commit.author!.name!, "John Doe")
    XCTAssertEqual(commit.author!.login!, "jdoe")
    XCTAssertEqual(commit.committer!.email!, "john.doe@gmail.com")
    XCTAssertEqual(commit.committer!.name!, "John Doe")
    XCTAssertEqual(commit.committer!.login!, "jdoe")
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 1, "1 record exists")
    Commit.MR_importFromObject(obj)
    Commit.MR_importFromObject(obj)
    XCTAssertEqual(Int(Commit.MR_countOfEntities()), 1, "1 record exists")
    XCTAssertEqual(Int(User.MR_countOfEntities()), 1, "1 record exists")
    
  }
  
}