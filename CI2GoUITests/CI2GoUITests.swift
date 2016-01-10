//
//  CI2GoUITests.swift
//  CI2GoUITests
//
//  Created by Atsushi Nagase on 1/11/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import XCTest

class CI2GoUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment = [
            "REALM_DB_NAME": "ci2go-uitest.realm",
            "CLEAR_REALM_DB": "1",
            "VERBOSE": "1",
            "TEST": "1"
        ]
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
    }
    
}
