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
        var user: User?
        afterEach {
            try! realm.write { realm.deleteAll() }
        }
        sharedExamples("Mapped Default User") {
            expect(user!.email).to(equal("atsn.ngs@gmail.com"))
            expect(user!.name).to(equal("Atsushi NAGASE"))
            expect(user!.login).to(equal("ngs"))
        }
        describe("Map User from JSON") {
            it("maps to me json") {
                let json = fixtureJSON("me.json", self.dynamicType)
                try! realm.write {
                    realm.add(Mapper<User>().map(json)!, update: false)
                }
                expect(realm.objects(User).count).to(equal(1))
                user = realm.objects(User).first
                itBehavesLike("Mapped Default User")
            }
        }
        describe("get me") {
            it("responses mapped user") {
                stub(isHost("circleci.com")) { _ in
                    let stubPath = OHPathForFile("me.json", self.dynamicType)
                    return fixture(stubPath!, headers: ["Content-Type":"application/json"])
                }
                waitUntil { done in
                    _ = User.me("test").subscribe(
                        onNext: {
                            user = $0
                            let users = realm.objects(User).sort()
                            expect(users.count).to(equal(5))
                            expect(realm.objects(User).count).to(equal(5))
                            expect(realm.objects(User)[0].email).to(equal("atsn.ngs@gmail.com"))
                            expect(realm.objects(User)[1].email).to(equal("atsushi.nagase@littleapps.co.jp"))
                            expect(realm.objects(User)[2].email).to(equal("a@ngs.io"))
                            expect(realm.objects(User)[3].email).to(equal("nagase@ngsdev.org"))
                            expect(realm.objects(User)[4].email).to(equal("ngs@oneteam.co.jp"))
                            itBehavesLike("Mapped Default User")
                            done()
                        },
                        onError: { _ in
                            fail("failed")
                            done()
                        }
                    )
                }
            }
        }
    }
}

