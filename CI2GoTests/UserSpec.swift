//
//  UserSpec.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/3/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Quick
import Nimble
import OHHTTPStubs
import ObjectMapper

@testable import CI2Go

class UserSpec: QuickSpec {
    override func spec() {
        let realm = try! Realm()
        var user: User!
        afterEach {
            try! realm.write { realm.deleteAll() }
        }
        sharedExamples("Mapped Default User") { (sharedExampleContext: SharedExampleContext) in
            describe("mapped result") {
                it("is mapped correctly") {
                    expect(user.email).to(equal("atsn.ngs@gmail.com"))
                    expect(user.name).to(equal("Atsushi NAGASE"))
                    expect(user.login).to(equal("ngs"))
                }
            }
        }
        describe("Map User from JSON") {
            beforeEach {
                let json = fixtureJSON("me.json", self.dynamicType)
                try! realm.write {
                    realm.add(Mapper<User>().map(json)!, update: false)
                    user = realm.objects(User).first
                }
            }
            it("maps to me json") {
                expect(realm.objects(User).count).to(equal(1))
            }
            itBehavesLike("Mapped Default User") { ["user": user] }
        }
        describe("get me") {
            beforeEach {
                stub(isHost("circleci.com")) { _ in
                    let stubPath = OHPathForFile("me.json", self.dynamicType)
                    return fixture(stubPath!, headers: ["Content-Type":"application/json"])
                }
                user = User.me("test").futureValue()
            }
            it("responses mapped user") {
                let users = realm.objects(User).sort()
                expect(users.count).to(equal(5))
                expect(realm.objects(User).count).to(equal(5))
                expect(realm.objects(User)[0].email).to(equal("atsn.ngs@gmail.com"))
                expect(realm.objects(User)[1].email).to(equal("atsushi.nagase@littleapps.co.jp"))
                expect(realm.objects(User)[2].email).to(equal("a@ngs.io"))
                expect(realm.objects(User)[3].email).to(equal("nagase@ngsdev.org"))
                expect(realm.objects(User)[4].email).to(equal("ngs@oneteam.co.jp"))
            }
            itBehavesLike("Mapped Default User")
        }
    }
}

