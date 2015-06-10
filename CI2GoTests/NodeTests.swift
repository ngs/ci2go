//
//  NodeTests.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import XCTest
import CI2Go

class NodeTests: XCTestCase {

  override func setUp() {
    Node.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
  }

  func testImportObject() {
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 0, "0 record exist")
    let obj = (((fixtureData("build") as! NSDictionary)["node"] as! NSArray)[0] as! NSDictionary)
    let node = Node.MR_importFromObject(obj)
    XCTAssertEqual(node.imageID, "circletar-0266-843f4-20141022T174739Z")
    XCTAssertEqual(node.port, 64587, "Port should be 64587")
    XCTAssertFalse(node.sshEnabled.boolValue, "SSH Enabled should be false")
    XCTAssertEqual(node.publicIPAddress, "23.20.76.84", "public IP address should equal 23.20.76.84")
    XCTAssertEqual(node.username, "ubuntu", "Username equal ubuntu")
    XCTAssertEqual(node.nodeID, "ubuntu@23.20.76.84:64587/circletar-0266-843f4-20141022T174739Z", "node id is generated")
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 1, "1 record exists")
    Node.MR_importFromObject(obj)
    Node.MR_importFromObject(obj)
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 1, "1 record exists")
  }

  func testImportObject2() {
    Node.MR_deleteAllMatchingPredicate(NSPredicate(format: "0 < 1"))
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 0, "0 record exist")
    let obj = (((fixtureData("build") as! NSDictionary)["node"] as! NSArray)[1] as! NSDictionary)
    let node = Node.MR_importFromObject(obj)
    XCTAssertEqual(node.imageID, "circletar-0266-843f4-20141022T174739Z")
    XCTAssertEqual(node.port, 64770, "Port should be 64770")
    XCTAssertTrue(node.sshEnabled.boolValue, "SSH Enabled should be true")
    XCTAssertEqual(node.publicIPAddress, "54.91.144.112", "public IP address should equal 54.91.144.112")
    XCTAssertEqual(node.username, "ubuntu", "Username equal ubuntu")
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 1, "1 record exists")
    Node.MR_importFromObject(obj)
    Node.MR_importFromObject(obj)
    XCTAssertEqual(Int(Node.MR_countOfEntities()), 1, "1 record exists")
  }
}