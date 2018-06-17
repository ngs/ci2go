//
//  DecodingTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class DecodingTests: XCTestCase {
    
    func testDecodingUser1() {
        let data = try! Data(json: "user1")
        let decoder = JSONDecoder()
        let user = try! decoder.decode(User.self, from: data)
        XCTAssertEqual("ngs", user.login)
        XCTAssertEqual(URL(string: "https://avatars0.githubusercontent.com/u/18631?v=4")!, user.avatarURL)
        XCTAssertEqual("Atsushi NAGASE", user.name)
        XCTAssertEqual(VCS.github, user.vcs!)
        XCTAssertEqual(18631, user.id)
    }
    
    func testDecodingCommit1() {
        let data = try! Data(json: "commit1")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let commit = try! decoder.decode(Commit.self, from: data)
        XCTAssertEqual("test", commit.body)
        XCTAssertEqual("develop-2", commit.branch)
        XCTAssertEqual("40d6291e9b38e02d3c6a36d922ee9906525496da", commit.hash)
        XCTAssertEqual("Initial import", commit.subject)
        XCTAssertEqual(URL(string: "https://github.com/ngs/ci2go/commit/40d6291e9b38e02d3c6a36d922ee9906525496da")!, commit.URL)
        XCTAssertEqual("ngs", commit.committerLogin)
        XCTAssertEqual("Atsushi Nagase", commit.committerName)
        XCTAssertEqual("a@ngs.io", commit.committerEmail)
        XCTAssertEqual(Date(timeIntervalSince1970: 1529192628), commit.committerDate)
        XCTAssertEqual("ngs2", commit.authorLogin)
        XCTAssertEqual("Atsushi Nagase 2", commit.authorName)
        XCTAssertEqual("a2@ngs.io", commit.authorEmail)
        XCTAssertEqual(Date(timeIntervalSince1970: 1529192629), commit.authorDate)
    }
    
    func testDecodingBuildDetail() {
        let data = try! Data(json: "build-detail")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let build = try! decoder.decode(Build.self, from: data)
        XCTAssertEqual([
            1, 1, 1, 1, 1, 1, 1, 1, 1
            ], build.steps.map { $0.actions.count })
        XCTAssertEqual([
            "Spin up Environment", "Checkout code", "Restoring Cache",
            ".circleci/bootstrap-carthage.sh", "Saving Cache",
            "sudo gem install fastlane", "fastlane set_build_number",
            "fastlane tests", "Uploading artifacts"
            ], build.steps.map { $0.name })
    }
    
    func testDecodingRecentBuilds() {
        let data = try! Data(json: "recent-builds")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let builds = try! decoder.decode([Build].self, from: data)
        builds.forEach { build in
            XCTAssertNotNil(build.compareURL)
        }
        
    }
    
}
