//
//  String+humanizeTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import XCTest
import CI2Go

class String_humanizeTests: XCTestCase {

  func testHumanize() {
    XCTAssertEqual("i_am_human".humanize, "I Am Human")
  }

}
