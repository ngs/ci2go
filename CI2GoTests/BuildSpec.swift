//
//  BuildSpec.swift
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

class BuildSpec: QuickSpec {
    override func spec() {
        let realm = try! Realm()
        sharedExamples("Mapped Build") {
            let build = realm.objects(Build).first!
            let project = realm.objects(Project).first!
            let branch = realm.objects(Branch).first!
            let commit = realm.objects(Commit).first!
            expect(realm.objects(Commit).count).to(equal(1))
            expect(build.compareURL).to(equal(NSURL(string: "https://github.com/ngs/ci2go/compare/ef1e276c2831...722f7dbc7b56")!))
            expect(build.number).to(equal(204))
            expect(build.sshEnabled).to(beFalse())
            expect(build.lifecycle).to(equal(Build.Lifecycle.Finished))
            expect(build.status).to(equal(Build.Status.Failed))
            expect(build.outcome).to(equal(Build.Outcome.Failed))
            expect(build.circleYAML).to(beginWith("machine:\n"))
            expect(build.stoppedAt).notTo(beNil())
            expect(build.startedAt).notTo(beNil())
            expect(build.queuedAt).notTo(beNil())
            expect(build.timeMillis).to(equal(1193845))
            expect(build.commits.count).to(equal(1))
            expect(build.commits.first!).to(equal(commit))
            expect(build.triggeredCommit).to(equal(commit))
            expect(build.why).to(equal("github"))

            expect(commit.sha1).to(equal("722f7dbc7b567b94cc59e0dca53a7873a1bbec86"))
            expect(commit.authedAt).notTo(beNil())
            expect(commit.commitedAt).notTo(beNil())
            expect(commit.author).notTo(beNil())
            expect(commit.committer).notTo(beNil())

            expect(project.parallelCount).to(equal(1))
            expect(project.repositoryName).to(equal("ci2go"))
            expect(project.username).to(equal("ngs"))
            expect(project.vcsURL).to(equal(NSURL(string: "https://github.com/ngs/ci2go")!))
            expect(project.id).to(equal("project/ngs/ci2go"))
            expect(project.isOpenSource).to(beTrue())
            expect(branch.name).to(equal("refactor"))
            expect(branch.project).to(equal(project))
            expect(branch.id).to(equal("project/ngs/ci2go:refactor"))
        }
        afterEach {
            try! realm.write { realm.deleteAll() }
        }
        describe("Map Build from JSON") {
            it("maps standard") {
                let json = fixtureJSON("builds.json", self.dynamicType)[0]!
                try! realm.write {
                    realm.add(Mapper<Build>().map(json)!, update: true)
                    realm.add(Mapper<Build>().map(json)!, update: true)
                }
                expect(realm.objects(Commit).count).to(equal(1))
                expect(realm.objects(Build).count).to(equal(1))
                expect(realm.objects(Project).count).to(equal(1))
                expect(realm.objects(Branch).count).to(equal(1))
                expect(realm.objects(Branch)[0].id).to(equal("project/ngs/ci2go:refactor"))
                expect(realm.objects(User).count).to(equal(1))
                expect(realm.objects(BuildStep).count).to(equal(0))
                expect(realm.objects(Build)[0].number).to(equal(204))
                itBehavesLike("Mapped Build")
            }
            it("maps detailed JSON") {
                let json = fixtureJSON("build.json", self.dynamicType)
                try! realm.write {
                    realm.add(Mapper<Build>().map(json)!, update: true)
                    realm.add(Mapper<Build>().map(json)!, update: true)
                }
                expect(realm.objects(Commit).count).to(equal(1))
                expect(realm.objects(Build).count).to(equal(1))
                expect(realm.objects(Project).count).to(equal(1))
                expect(realm.objects(User).count).to(equal(1))
                expect(realm.objects(Branch).count).to(equal(1))
                expect(realm.objects(Build)[0].number).to(equal(204))

                itBehavesLike("Mapped Build")
            }
        }
        describe("getRecent") {
            stub(isHost("circleci.com")) { _ in
                let stubPath = OHPathForFile("builds.json", self.dynamicType)
                return fixture(stubPath!, headers: ["Content-Type":"application/json"])
            }
            it("resposes recent builds") {
                waitUntil { done in
                    _ = Build.getRecent().subscribe(
                        onNext: { builds in
                            expect(builds.count).to(equal(20))
                            expect(realm.objects(Build).count).to(equal(20))
                            let ar = realm.objects(Build).map { $0.id }
                            expect(ar).to(equal([
                                "project/ngs/ci2go/204",
                                "project/ngs/ci2go/200",
                                "project/ngs/ci2go/199",
                                "project/ngs/ci2go/198",
                                "project/ngs/ci2go/197",
                                "project/ngs/ci2go/196",
                                "project/ngs/ci2go/195",
                                "project/ngs/ci2go/193",
                                "project/ngs/ci2go/192",
                                "project/ngs/ci2go/191",
                                "project/ngs/ci2go/190",
                                "project/ngs/ci2go/187",
                                "project/ngs/ci2go/186",
                                "project/ngs/ci2go/185",
                                "project/ngs/ci2go/184",
                                "project/ngs/ci2go/183",
                                "project/ngs/ci2go/182",
                                "project/ngs/ci2go/180",
                                "project/ngs/ci2go/179",
                                "project/ngs/ci2go/175"]))
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
