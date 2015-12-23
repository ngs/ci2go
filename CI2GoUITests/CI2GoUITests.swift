//
//  CI2GoUITests.swift
//  CI2GoUITests
//
//  Created by Atsushi Nagase on 12/23/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import XCTest

class CI2GoUITests: XCTestCase {

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testExample() {
  }

}
