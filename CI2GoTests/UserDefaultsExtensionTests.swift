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
    

    func testColorScheme() {
        let d = UserDefaults()
        d.removeObject(forKey: UserDefaults.Key.colorScheme.rawValue)
        XCTAssertEqual(d.colorScheme.name, "Github")
        d.set("Foo", forKey: .colorScheme)
        XCTAssertEqual(d.colorScheme.name, "Github")
        d.set("Tomorrow Night", forKey: .colorScheme)
        XCTAssertEqual(d.colorScheme.name, "Tomorrow Night")
    }

    func testBranch() {
        let d = UserDefaults()
        d.removeObject(forKey: UserDefaults.Key.branch.rawValue)
        XCTAssertNil(d.branch)
        d.branch = nil
        XCTAssertNil(d.branch)
        let branch = Branch(Project(vcs: .github, username: "ngs", name: "ci2go"), "master")
        d.branch = branch
        XCTAssertEqual(d.branch!, branch)
    }
}
