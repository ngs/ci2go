//
//  ColorSchemesViewControllerTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import XCTest
import CI2Go

class ColorSchemesViewControllerTests: XCTestCase {
  func testSectionIndexes() {
    let c = ColorSchemesViewController()
    XCTAssertEqual(c.sectionIndexes, [
      "3", "A", "B", "C", "D", "E", "F", "G", "H", "I",
      "J", "K", "L", "M", "N", "O", "P", "R", "S",
      "T", "U", "V", "W", "Z", "i"], "lists section indexes")
  }
  func testSections() {
    let c = ColorSchemesViewController()
    XCTAssertEqual(c.sections.count, c.sectionIndexes.count, "lists sections")
  }
}