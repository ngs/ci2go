//
//  CompensationTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class CompensationTests: XCTestCase {

    func testEqualProjects() {
        var project1 = Project(vcs: .github, username: "ngs", name: "ci2go")
        var project2 = Project(vcs: .github, username: "ngs", name: "ci2go")
        XCTAssertTrue(project1 == project2)

        project1 = Project(vcs: .github, username: "ngs", name: "ci2go")
        project2 = Project(vcs: .bitbucket, username: "ngs", name: "ci2go")
        XCTAssertFalse(project1 == project2)
    }

    func testComparingProjects() {
        var project1 = Project(vcs: .github, username: "ngs", name: "ci2go")
        var project2 = Project(vcs: .bitbucket, username: "ngs", name: "ci2go")
        XCTAssertFalse(project1 < project2)
        XCTAssertFalse(project1 > project2)

        project1 = Project(vcs: .github, username: "ngs", name: "ci2go")
        project2 = Project(vcs: .bitbucket, username: "ngs", name: "ci3go")
        XCTAssertTrue(project1 < project2)
        XCTAssertFalse(project1 > project2)
    }

    func testEqualBuilds() {
        let data = try! Data(json: "recent-builds") // swiftlint:disable:this force_try
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let builds = try! decoder.decode([Build].self, from: data) // swiftlint:disable:this force_try

        XCTAssertTrue(builds[0] == builds[0])
        XCTAssertFalse(builds[0] == builds[1])
    }

    func testComparingBuilds() {
        let data = try! Data(json: "recent-builds") // swiftlint:disable:this force_try
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let builds = try! decoder.decode([Build].self, from: data) // swiftlint:disable:this force_try

        XCTAssertFalse(builds[0] < builds[0])
        XCTAssertFalse(builds[0] > builds[0])

        XCTAssertFalse(builds[0] < builds[1])
        XCTAssertTrue(builds[0] > builds[1])
    }

    func testComparingBuildsWithoutTimestamp() {
        let project = Project(vcs: .github, username: "ngs", name: "ci2go")
        let build1 = Build(project: project, number: 100)
        let build2 = Build(project: project, number: 101)

        XCTAssertTrue(build1 < build2)
        XCTAssertFalse(build1 > build2)
    }
}
