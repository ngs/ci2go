//
//  BuildStepsViewControllerSpec.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/5/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Quick
import Nimble
import OHHTTPStubs
import ObjectMapper

@testable import CI2Go

class BuildStepsViewControllerSpec: QuickSpec {
    func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle(forClass: AppDelegate.self))
    }
    func createViewController(realm: Realm) -> BuildStepsViewController {
        let realm = try! Realm()
        let json = fixtureJSON("builds.json", self.dynamicType)[0]!
        try! realm.write {
            realm.add(Mapper<Build>().map(json)!, update: true)
        }
        let build = realm.objects(Build).first!
        let vc = mainStoryboard().instantiateViewControllerWithIdentifier("BuildStepsViewController") as! BuildStepsViewController
        vc.build = build
        vc.loadView()
        return vc
    }
    override func spec() {
        var realm: Realm!
        var vc: BuildStepsViewController!
        beforeEach {
            realm = try! Realm()
            vc = self.createViewController(realm)
            stub(isHost("circleci.com")) { _ in
                let stubPath = OHPathForFile("build.json", self.dynamicType)
                return fixture(stubPath!, headers: ["Content-Type":"application/json"])
            }
        }
        afterEach {
            try! realm.write { realm.deleteAll() }
        }
        describe("Initializing") {
            it("initializes") {
                expect(vc).notTo(beNil())
                expect(realm.objects(BuildAction).count).to(equal(0))
            }
            it("loads build actions from build") {
                vc.refresh(nil)
                expect(vc.isLoading).to(beTruthy())
                waitUntil(timeout: 10000) { done in
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
                        expect(vc.isLoading).to(beFalsy())
                        expect(vc.numberOfSectionsInTableView(vc.tableView)).to(equal(8))
                        expect(realm.objects(BuildAction).count).to(equal(39))
                        expect(vc.tableView(vc.tableView, numberOfRowsInSection: 0)).to(equal(3))
                        expect(vc.tableView(vc.tableView, numberOfRowsInSection: 1)).to(equal(2))
                        expect(vc.tableView(vc.tableView, numberOfRowsInSection: 2)).to(equal(5))
                        expect(vc.tableView(vc.tableView, numberOfRowsInSection: 3)).to(equal(18))
                        expect(vc.tableView(vc.tableView, numberOfRowsInSection: 4)).to(equal(1))
                        expect(vc.tableView(vc.tableView, numberOfRowsInSection: 5)).to(equal(2))
                        expect(vc.tableView(vc.tableView, numberOfRowsInSection: 6)).to(equal(4))
                        expect(vc.tableView(vc.tableView, numberOfRowsInSection: 7)).to(equal(4))
                        done()
                    })
                }
            }
        }
    }
}