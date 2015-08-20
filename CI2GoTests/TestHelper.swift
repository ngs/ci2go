//
//  TestHelper.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/6/14.
//
//

import Foundation

func testBundle() -> NSBundle {
  return NSBundle(forClass: CI2GoUserDefaultsTests.self)
}

func fixturePath(name: String) -> String? {
  return testBundle().pathForResource(name, ofType: "json")
}

func fixtureData(name: String) -> AnyObject {
  var error: NSError?
  var filePath = fixturePath(name)
  if filePath == nil { return NSDictionary() }
  var data: NSData? = NSData(contentsOfFile: filePath!, options: NSDataReadingOptions.DataReadingMappedAlways, error: &error)
  if data == nil { return NSDictionary() }
  return NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: &error)!
}
