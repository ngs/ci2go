//
//  BranchSpec.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Quick
import Nimble
import OHHTTPStubs
import ObjectMapper

@testable import CI2Go

class BranchSpec: QuickSpec {
    override func spec() {
        let realm = try! Realm()
        afterEach {
            try! realm.write { realm.deleteAll() }
        }
        pending("no tests") {}
    }
}