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
        let defaults = UserDefaults()
        defaults.removeObject(forKey: .colorScheme)
        defaults.removeObject(forKey: .branch)
        defaults.removeObject(forKey: .project)
    }

    func testColorScheme() {
        let defaults = UserDefaults()
        XCTAssertEqual(defaults.colorScheme.name, "Github")
        defaults.set("Foo", forKey: .colorScheme)
        XCTAssertEqual(defaults.colorScheme.name, "Github")
        defaults.set("Tomorrow Night", forKey: .colorScheme)
        XCTAssertEqual(defaults.colorScheme.name, "Tomorrow Night")
    }

    func testBranchAndProject() {
        let defaults = UserDefaults()
        XCTAssertNil(defaults.branch)
        XCTAssertNil(defaults.project)
        defaults.project = project
        defaults.branch = nil
        XCTAssertNil(defaults.branch)
        XCTAssertNil(defaults.project)
        defaults.project = project
        defaults.branch = branch
        XCTAssertEqual(defaults.branch!, branch)
        XCTAssertNil(defaults.project)
        defaults.project = project
        XCTAssertNil(defaults.branch)
        XCTAssertEqual(defaults.project!, project)
    }
}
