//
//  CI2GoTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/14.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class CI2GoTests: XCTestCase {

    func testGlobal() {
        XCTAssertTrue(isValidToken("0123456789abcdef0123456789abcdef01234567"))
        XCTAssertFalse(isValidToken("x123456789abcdef0123456789abcdef01234567"))
        XCTAssertFalse(isValidToken("00123456789abcdef0123456789abcdef01234567"))
        XCTAssertFalse(isValidToken(""))
    }
}
