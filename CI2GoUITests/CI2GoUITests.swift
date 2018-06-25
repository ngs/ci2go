//
//  CI2GoUITests.swift
//  CI2GoUITests
//
//  Created by Atsushi Nagase on 2018/06/14.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest

class CI2GoUITests: XCTestCase {

    let nonexistencePredicate = NSPredicate(format: "exists == false")
    let existencePredicate = NSPredicate(format: "exists == true")

    func randomHexString(length: Int) -> String {
        var string = ""
        for _ in 0..<length {
            string += String(format: "%01X", Int(arc4random_uniform(0x10)))
        }
        return string.lowercased()
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-colorSchemes=1,2,3,4,5,6,7,8"]
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testBuidList() {
        let app = XCUIApplication()
        var element: XCUIElement!

        expectation(for: nonexistencePredicate, evaluatedWith: app.activityIndicators.firstMatch, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)

        snapshot("0-Build-List")

        app.navigationBars["Builds"].buttons["Settings"].tap()

        element = app.tables["SettingsTableView"].cells["APITokenFieldCell"].textFields.element
        expectation(for: existencePredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssertTrue(element.exists)
        element.tap()
        element.typeText(randomHexString(length: 40))

        snapshot("5-Settings")

        element = app.tables["SettingsTableView"].cells["ColorSchemeTableViewCell"]
        expectation(for: existencePredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssertTrue(element.exists)
        element.tap()

        element = app.tables["ColorSchemeTableView"]
        expectation(for: existencePredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssertTrue(element.exists)

        snapshot("6-ColorScheme")

        app.navigationBars["Select theme"].buttons["Settings"].tap()
        app.navigationBars["Settings"].buttons["Cancel"].tap()

        app.navigationBars["Builds"].buttons["Select Project"].tap()

        element = app.tables["ProjectsTableView"].cells.element(matching: NSPredicate(block: { (attr, _) -> Bool in
            return (attr as? XCUIElementAttributes)?.label == "ci2go, ngs"
        }))
        expectation(for: existencePredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssertTrue(element.exists)

        snapshot("7-Projects")

        element.tap()

        element = app.tables["BranchesTableView"].cells["screenshots"]
        expectation(for: existencePredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssertTrue(element.exists)

        snapshot("8-Branches")

        element.tap()

        expectation(for: nonexistencePredicate, evaluatedWith: app.activityIndicators.firstMatch, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)

        element = app.tables["BuildsTableView"].cells.element(matching: NSPredicate(block: { (attr, _) -> Bool in
            guard let label = (attr as? XCUIElementAttributes)?.label else { return false }
            return (label.contains("Success") || label.contains("Fixed")) && label.contains("screenshots, screenshots")
        })).firstMatch
        expectation(for: existencePredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssertTrue(element.exists)
        element.tap()

        element = app.tables["BuildActionsTableView"].cells.element(matching: NSPredicate(block: { (attr, _) -> Bool in
            guard let label = (attr as? XCUIElementAttributes)?.label else { return false }
            return label.contains("fastlane screenshots")
        })).firstMatch
        expectation(for: existencePredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssertTrue(element.exists)

        element.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).tap()

        expectation(for: nonexistencePredicate, evaluatedWith: app.activityIndicators.firstMatch, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)

        snapshot("2-Build-Log")

        if app.navigationBars.element.buttons["Back"].exists {
            app.navigationBars.element.buttons["Back"].tap()
        }
        app.tables["BuildActionsTableView"].cells["BuildArtifactsCell"].firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).tap()

        element = app.tables["BuildArtifactsTableView"].cells["screenshots"]
        expectation(for: existencePredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssertTrue(element.exists)

        element.tap()

        snapshot("3-Build-Artifacts")

        app.navigationBars.element.buttons.firstMatch.tap()
        app.navigationBars.element.buttons.firstMatch.tap()

        element = app.tables["BuildActionsTableView"]
        element.swipeDown()

        snapshot("1-Build-Detail")

        element.cells["BuildConfigurationCell"].tap()

        snapshot("4-Build-Config")
    }
    
}
