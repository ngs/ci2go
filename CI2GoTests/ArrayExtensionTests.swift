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
    func testMergeElements() {
        var ar = [2, 3, 4, 5]
        let res = ar.merge(elements: [3, 1, 4, 6])
        XCTAssertEqual([1, 2, 3, 4, 5, 6], ar)
        XCTAssertEqual(4, res.count)
        XCTAssertEqual(.updateRows([IndexPath(row: 1, section: 0)]), res[0])
        XCTAssertEqual(.insertRows([IndexPath(row: 0, section: 0)]), res[1])
        XCTAssertEqual(.updateRows([IndexPath(row: 3, section: 0)]), res[2])
        XCTAssertEqual(.insertRows([IndexPath(row: 5, section: 0)]), res[3])
    }
}
