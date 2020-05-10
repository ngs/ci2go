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
        defaults.removeObject(forKey: .branch)
        defaults.removeObject(forKey: .project)
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
