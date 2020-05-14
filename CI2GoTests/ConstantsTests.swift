//
//  ConstantsTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2020/05/14.
//  Copyright © 2020 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class ConstatntsTests: XCTestCase {

    func testIsTOTP() {
        XCTAssertEqual(false, isTOTP(""))
        XCTAssertEqual(false, isTOTP("aa"))
        XCTAssertEqual(false, isTOTP("111111111"))
        XCTAssertEqual(false, isTOTP("ああ"))
        XCTAssertEqual(true, isTOTP("962207"))
    }

    func testIsValidToken() {
        XCTAssertEqual(false, isValidToken(""))
        XCTAssertEqual(false, isValidToken("aa"))
        XCTAssertEqual(false, isValidToken("111111111"))
        XCTAssertEqual(false, isValidToken("ああ"))
        XCTAssertEqual(true, isValidToken("1c8e486fc496ba36cfa3c1efe4b2cb1eea95c735"))
    }
}
