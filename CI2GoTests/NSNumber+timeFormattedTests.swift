//
//  NSNumber+timeFormattedTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import XCTest
import CI2Go

class NSNumber_timeFormattedTests: XCTestCase {

  func testTimeFormatterd() {
    var n = 3000 as NSNumber
    XCTAssertEqual(n.timeFormatted, "00:03")
    n = (50 * 3600 + 5 * 60 + 30) * 1000 as NSNumber
    XCTAssertEqual(n.timeFormatted, "50:05:30")
    n = (2 * 3600 + 5 * 60 + 30) * 1000 as NSNumber
    XCTAssertEqual(n.timeFormatted, "2:05:30")

  }

}
