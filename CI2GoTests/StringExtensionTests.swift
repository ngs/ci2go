//
//  StringExtensionTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class StringExtensionTests: XCTestCase {

    func testHumanize() {
        XCTAssertEqual("Hello World", "hello_world".humanize)
    }

}
