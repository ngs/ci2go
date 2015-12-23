//
//  ColorSchemeTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import XCTest
import CI2Go

class ColorSchemeTests: XCTestCase {
  override func tearDown() {
    CI2GoUserDefaults.standardUserDefaults().colorSchemeName = nil
  }
  
  func testNames() {
    XCTAssertEqual(ColorScheme.names().count, 116, "Has 116 color schemes")
  }
  
  func testName() {
    let s = ColorScheme(name: "Tomorrow Night")
    XCTAssert(s.name == "Tomorrow Night", "name property is assigned")
  }
  
  func testDictionary() {
    let s = ColorScheme(name: "Github")
    XCTAssertNotNil(s.dictionary, "Dictionary is not nil")
    let keys = s.dictionary.keys.sort()
    XCTAssertEqual(keys, ["Selected Text Color", "Ansi 10 Color", "Background Color", "Ansi 4 Color", "Foreground Color", "Ansi 8 Color", "Ansi 2 Color", "Ansi 1 Color", "Ansi 11 Color", "Cursor Color", "Ansi 7 Color", "Ansi 3 Color", "Ansi 14 Color", "Ansi 0 Color", "Bold Color", "Ansi 6 Color", "Selection Color", "Ansi 9 Color", "Cursor Text Color", "Ansi 13 Color", "Ansi 5 Color", "Ansi 12 Color", "Ansi 15 Color"], "Has keys")
    let dict = s.dictionary["Foreground Color"]
    XCTAssertEqual(dict!.keys.sort(), ["Green Component", "Red Component", "Blue Component"])
  }
  
  func testColorByKey() {
    let s = ColorScheme(name: "Tomorrow Night")
    XCTAssertNotNil(s.color(key: "Foreground"), "Foreground color is not nil")
    XCTAssertNotNil(s.color(key: "Background"), "Foreground color is not nil")
  }
}