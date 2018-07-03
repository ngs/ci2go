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

    func testDecodingUser2() {
        let data = try! Data(json: "user2")
        let decoder = JSONDecoder()
        let user = try! decoder.decode(User.self, from: data)
        XCTAssertEqual("ci2go", user.login)
        XCTAssertEqual(URL(string: "https://avatars1.githubusercontent.com/u/40327043?v=4")!, user.avatarURL)
        XCTAssertEqual("CI2Go", user.name)
        XCTAssertNil(user.vcs)
        XCTAssertNil(user.id)
    }

    func testDecodingCommit1() {
        let data = try! Data(json: "commit1")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ try DateDecoder.decode($0) })
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
        decoder.dateDecodingStrategy = .custom({ try DateDecoder.decode($0) })
        let build = try! decoder.decode(Build.self, from: data)
        XCTAssertEqual("Atsushi NAGASE", build.user!.name)
        XCTAssertEqual("ngs", build.user!.login)
        XCTAssertEqual([
            1, 1, 1, 1, 1, 1, 1, 1, 1
            ], build.steps.map { $0.actions.count })
        XCTAssertEqual([
            0, 101, 102, 103, 104, 105, 106, 107, 108
            ], build.steps.map { $0.actions.first!.step })
        XCTAssertEqual([
            "Spin up Environment",
            "Checkout code",
            "Restoring Cache",
            ".circleci/bootstrap-carthage.sh",
            "Saving Cache",
            "sudo gem install fastlane",
            "fastlane set_build_number",
            "fastlane tests",
            "Uploading artifacts"
            ], build.steps.map { $0.name })
    }

    func testDecodingRecentBuilds() {
        let data = try! Data(json: "recent-builds")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ try DateDecoder.decode($0) })
        let builds = try! decoder.decode([Build].self, from: data)
        XCTAssertEqual([
            "https://github.com/ngs/ci2go/compare/f6db837b6166...40d6291e9b38",
            "https://github.com/ngs/ci2go/compare/837a9ccda223...f6db837b6166",
            "https://github.com/ngs/ci2go/compare/e952572ea5ee...837a9ccda223",
            "https://github.com/ngs/ci2go/compare/b9f5e29d0e87...4b64b0309af2",
            "https://github.com/ngs/ci2go/compare/b9f5e29d0e87...4b64b0309af2",
            "https://github.com/ngs/ci2go/compare/caaafe1949cb...b9f5e29d0e87",
            "https://github.com/ngs/ci2go/compare/caaafe1949cb...b9f5e29d0e87",
            "https://github.com/ngs/ci2go/compare/801c13c699cd...caaafe1949cb",
            "https://github.com/ngs/ci2go/compare/801c13c699cd...caaafe1949cb",
            "https://github.com/ngs/ci2go/compare/801c13c699cd...caaafe1949cb",
            "https://github.com/ngs/ci2go/compare/2b01af821bca...801c13c699cd",
            "https://github.com/ngs/ci2go/compare/2b01af821bca...801c13c699cd",
            "https://github.com/ngs/ci2go/compare/987c40f4f543...2b01af821bca",
            "https://github.com/ngs/ci2go/compare/987c40f4f543...2b01af821bca",
            "https://github.com/ngs/ci2go/commit/987c40f4f543",
            "https://github.com/ngs/ci2go/commit/987c40f4f543",
            "https://github.com/ngs/ci2go/commit/987c40f4f543",
            "https://github.com/ngs/ci2go/commit/987c40f4f543",
            "https://github.com/ngs/ci2go/commit/987c40f4f543",
            "https://github.com/ngs/ci2go/compare/7c21d356b02a...a5bf608c4ffe",
            "https://github.com/ngs/ci2go/compare/7c21d356b02a...a5bf608c4ffe",
            "https://github.com/ngs/ci2go/compare/7c21d356b02a...a5bf608c4ffe",
            "https://github.com/ngs/ci2go/compare/3d2a55c2303e...10ca28e975be",
            "https://github.com/ngs/ci2go/compare/3d2a55c2303e...10ca28e975be",
            "https://github.com/ngs/ci2go/compare/7c21d356b02a...a5bf608c4ffe",
            "https://github.com/ngs/ci2go/compare/4b59fd585ca0...bfab94908b6f",
            "https://github.com/ngs/ci2go/commit/4b59fd585ca0",
            "https://github.com/ngs/ci2go/commit/4b59fd585ca0",
            "https://github.com/ngs/ci2go/commit/4b59fd585ca0",
            "https://github.com/ngs/ci2go/commit/3d2a55c2303e"
            ], builds.map { $0.compareURL!.absoluteString })
        XCTAssertEqual([
            "Initial import",
            "Initial import",
            "Initial Commit",
            "Create test scheme",
            "Create test scheme",
            "Store CocoaPods Cache",
            "Store CocoaPods Cache",
            "Store CocoaPods Cache",
            "Store CocoaPods Cache",
            "Store CocoaPods Cache",
            "Use Xcode 9.1.0",
            "Use Xcode 9.1.0",
            "Use Xcode 9.1.0",
            "Use Xcode 9.1.0",
            "Start refactoring using modern tools",
            "Start refactoring using modern tools",
            "Start refactoring using modern tools",
            "Start refactoring using modern tools",
            "Start refactoring using modern tools",
            "Stop using legacy API from gym",
            "Stop using legacy API from gym",
            "Stop using legacy API from gym",
            "https://bugsee.com/",
            "https://bugsee.com/",
            "Stop using legacy API from gym",
            "Set skip_waiting_for_build_processing to true",
            "Stop using legacy API from gym",
            "Stop using legacy API from gym",
            "Stop using legacy API from gym",
            "https://bugsee.com/"
            ], builds.map { $0.body })
        XCTAssertEqual([
            479, 478, 477, 476, 475, 474,
            473, 472, 471, 470, 469, 468,
            467, 466, 465, 464, 463, 462,
            461, 460, 459, 458, 457, 456,
            455, 454, 453, 452, 451, 450
            ], builds.map { $0.number })
        XCTAssertEqual([
            "app",
            "app",
            "app",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "<no-workflows>",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "<no-workflows>",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>",
            "<no-workflows>"
            ], builds.map { $0.workflow?.name ?? "<no-workflows>" })
        XCTAssertEqual([
            "tests",
            "tests",
            "tests",
            "build-and-test",
            "swiftlint",
            "build-and-test",
            "swiftlint",
            "<no-job-name>",
            "swiftlint",
            "build-and-test",
            "swiftlint",
            "build-and-test",
            "build-and-test",
            "swiftlint",
            "<no-job-name>",
            "build-and-test",
            "build-and-test",
            "build-and-test",
            "swiftlint",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>",
            "<no-job-name>"
            ], builds.map { $0.jobName ?? "<no-job-name>" })
    }

    func testDecodingProjects() {
        let data = try! Data(json: "projects")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ try DateDecoder.decode($0) })
        let projects = try! decoder.decode([Project].self, from: data)
        XCTAssertEqual(["master", "campfire", "ruby-2.4.0", "ts-dakoku"], projects[0].branches.map { $0.name })
        XCTAssertEqual(["sources.ngs.io", "ci2go", "ci2go.com", "ci2go.com"], projects.map { $0.name })
        XCTAssertEqual([
            "https://github.com/ngs/sources.ngs.io",
            "https://github.com/ngs/ci2go",
            "https://github.com/ngs/ci2go.com",
            "https://bitbucket.org/ngs/ci2go.com"
            ], projects.map { $0.vcsURL!.absoluteString })
    }

    func testBranchAPIPath() {
        let project = Project(vcs: .github, username: "ngs", name: "ci2go")
        XCTAssertEqual("/project/github/ngs/ci2go/tree/%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AFabc", Branch(project, "こんにちはabc").apiPath)
        XCTAssertEqual("/project/github/ngs/ci2go/tree/ruby%2D2%2E4%2E0", Branch(project, "ruby-2.4.0").apiPath)
    }
}
