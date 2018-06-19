//
//  ArrayExtensionTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class ArrayExtensionTests: XCTestCase {
    func testMergedBuilds() {
        let project = Project(vcs: .github, username: "ngs", name: "ci2go")
        let ar1 = [
            Build(project: project, number: 1, status: .running),
            Build(project: project, number: 2, status: .running),
            Build(project: project, number: 3, status: .running),
            Build(project: project, number: 4, status: .running),
            Build(project: project, number: 5, status: .running)
        ]
        let ar2 = [
            Build(project: project, number: 2, status: .failed),
            Build(project: project, number: 4, status: .running),
            Build(project: project, number: 3, status: .success),
            Build(project: project, number: 5, status: .running),
            Build(project: project, number: 6, status: .running)
        ]
        let ar3 = ar1.merged(with: ar2)
        XCTAssertEqual([
            Build(project: project, number: 1, status: .running),
            Build(project: project, number: 2, status: .failed),
            Build(project: project, number: 3, status: .success),
            Build(project: project, number: 4, status: .running),
            Build(project: project, number: 5, status: .running),
            Build(project: project, number: 6, status: .running)
            ], ar3)
    }
}
