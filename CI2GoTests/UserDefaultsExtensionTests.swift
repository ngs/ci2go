//
//  UserDefaultsExtensionTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class UserDefaultsExtensionTests: XCTestCase {

    var project: Project!
    var branch: Branch!

    override func setUp() {
        super.setUp()
        project = Project(vcs: .github, username: "ngs", name: "ci2go")
        branch = Branch(project, "master")
        let d = UserDefaults()
        d.removeObject(forKey: .colorScheme)
        d.removeObject(forKey: .branch)
        d.removeObject(forKey: .project)
    }

    func testColorScheme() {
        let d = UserDefaults()
        XCTAssertEqual(d.colorScheme.name, "Github")
        d.set("Foo", forKey: .colorScheme)
        XCTAssertEqual(d.colorScheme.name, "Github")
        d.set("Tomorrow Night", forKey: .colorScheme)
        XCTAssertEqual(d.colorScheme.name, "Tomorrow Night")
    }

    func testBranchAndProject() {
        let d = UserDefaults()
        XCTAssertNil(d.branch)
        XCTAssertNil(d.project)
        d.project = project
        d.branch = nil
        XCTAssertNil(d.branch)
        XCTAssertNil(d.project)
        d.project = project
        d.branch = branch
        XCTAssertEqual(d.branch!, branch)
        XCTAssertNil(d.project)
        d.project = project
        XCTAssertNil(d.branch)
        XCTAssertEqual(d.project!, project)
    }
}
