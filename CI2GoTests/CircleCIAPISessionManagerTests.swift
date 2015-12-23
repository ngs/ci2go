//
//  CircleCIAPISessionManagerTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import XCTest
import CI2Go

class CircleCIAPISessionManagerTests: XCTestCase {
  
  override func setUp() {
    CI2GoUserDefaults.standardUserDefaults().reset()
  }
  
  func testAPIToken() {
    let m = CircleCIAPISessionManager()
    XCTAssertTrue(m.requestSerializer.isKindOfClass(CircleCIRequestSerializer.self), "request serializer is a CircleCIRequestSerializer")
    XCTAssertNil((m.requestSerializer as! CircleCIRequestSerializer).apiToken, "apiToken is nil")
  }
  
  func testAPITokenInConstructor() {
    let m = CircleCIAPISessionManager(apiToken: "foo")
    XCTAssert((m.requestSerializer as! CircleCIRequestSerializer).apiToken == "foo", "apiToken is assigned")
    XCTAssert(m.apiToken == "foo", "apiToken is assigned")
  }
  
  func testAPITokenInUserDefaults() {
    CI2GoUserDefaults.standardUserDefaults().circleCIAPIToken = "foo"
    let m = CircleCIAPISessionManager()
    XCTAssert((m.requestSerializer as! CircleCIRequestSerializer).apiToken == "foo", "apiToken is assigned")
    XCTAssert(m.apiToken == "foo", "apiToken is assigned")
  }
  
  func testAPITokenWithNilParameteres() {
    let m = CircleCIAPISessionManager()
    m.apiToken = "foo"
    let req = try? m.requestSerializer.requestWithMethod("GET", URLString: "http://www.foo.com/bar", parameters: nil, error: ())
    XCTAssert(req!.URL!.absoluteString == "http://www.foo.com/bar?circle-token=foo", "token is set")
  }
  
  func testAPITokenWithGetParameteres() {
    let m = CircleCIAPISessionManager()
    m.apiToken = "foo"
    let req = try? m.requestSerializer.requestWithMethod("GET", URLString: "http://www.foo.com/bar", parameters: (["foo": 123] as NSDictionary), error: ())
    XCTAssert(req!.URL!.absoluteString == "http://www.foo.com/bar?circle-token=foo&foo=123", "token is set")
  }
  
  func testAPITokenWithPostParameteres() {
    let m = CircleCIAPISessionManager()
    m.apiToken = "foo"
    let req = try? m.requestSerializer.requestWithMethod("POST", URLString: "http://www.foo.com/bar", parameters: (["foo": 123] as NSDictionary), error: ())
    XCTAssert(req!.URL!.absoluteString == "http://www.foo.com/bar?circle-token=foo", "token is set")
  }
  
}