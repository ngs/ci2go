//
//  CI2GoUserDefaultsTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/27/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import XCTest
import CI2Go

class CI2GoUserDefaultsTests: XCTestCase {
  
  override func setUp() {
    CI2GoUserDefaults.standardUserDefaults().reset()
  }
  
  func testColorSchemeName() {
    let d = CI2GoUserDefaults.standardUserDefaults()
    XCTAssertEqual(d.colorSchemeName!, "Github", "Default name is Github")
    d.colorSchemeName = "Tomorrow Night"
    XCTAssertEqual(d.colorSchemeName!, "Tomorrow Night", "Updated to Tomorrow Night")
    d.colorSchemeName = "Foo"
    XCTAssertEqual(d.colorSchemeName!, "Github", "Reverted to Github by setting invalid name")
    d.colorSchemeName = "Twilight"
    XCTAssertEqual(d.colorSchemeName!, "Twilight", "Updated to Twilight")
    d.colorSchemeName = nil
    XCTAssertEqual(d.colorSchemeName!, "Github", "Reverted to Github by setting nil")
  }
  
  func testCircleCIAPIToken() {
    let d = CI2GoUserDefaults.standardUserDefaults()
    XCTAssertNil(d.circleCIAPIToken, "Default is nil")
    d.circleCIAPIToken = "asdf1234asdf1234asdf1234asdf1234asdf1234asdf1234"
    XCTAssertEqual(d.circleCIAPIToken!, "asdf1234asdf1234asdf1234asdf1234asdf1234asdf1234", "Stored value correctly")
    d.circleCIAPIToken = nil
    XCTAssertNil(d.circleCIAPIToken, "Default is nil")
  }
  
  func testLogRefreshInterval() {
    let d = CI2GoUserDefaults.standardUserDefaults()
    XCTAssertEqual(d.logRefreshInterval, 1.0, "Default is 1.0")
    d.logRefreshInterval = 2.5
    XCTAssertEqual(d.logRefreshInterval, 2.5, "Updated to 2.5")
  }
  
  func testAPIRefreshInterval() {
    let d = CI2GoUserDefaults.standardUserDefaults()
    XCTAssertEqual(d.apiRefreshInterval, 5.0, "Default is 5.0")
    d.apiRefreshInterval = 2.5
    XCTAssertEqual(d.apiRefreshInterval, 2.5, "Updated to 2.5")
  }
}
