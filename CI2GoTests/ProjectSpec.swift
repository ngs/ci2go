//
//  ProjectSpec.swift
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

class ProjectSpec: QuickSpec {
    override func spec() {
        let realm = try! Realm()
        afterEach {
            try! realm.write { realm.deleteAll() }
        }
        describe("Map Project from JSON") {
            it("maps standard") {
                let json = fixtureJSON("projects.json", self.dynamicType)[0]!
                try! realm.write {
                    realm.add(Mapper<Project>().map(json)!, update: true)
                    realm.add(Mapper<Project>().map(json)!, update: true)
                }
                expect(realm.objects(Project).count).to(equal(1))
                expect(realm.objects(Branch).count).to(equal(2))
                let project = realm.objects(Project).first!
                let branches = realm.objects(Branch).sorted("id")
                expect(project.parallelCount).to(equal(1))
                expect(project.repositoryName).to(equal("sources.ngs.io"))
                expect(project.username).to(equal("ngs"))
                expect(project.vcsURL).to(equal(NSURL(string: "https://github.com/ngs/sources.ngs.io")!))
                expect(project.id).to(equal("project/ngs/sources.ngs.io"))
                expect(project.isOpenSource).to(beTrue())
                expect(project.isFollowed).to(beTrue())
                expect(project.branches.count).to(equal(3))
                expect(branches[0].name).to(equal("2015-09-26-circleci-docker-serverspec"))
                expect(branches[0].project).to(equal(project))
                expect(branches[0].id).to(equal("project/ngs/sources.ngs.io:2015-09-26-circleci-docker-serverspec"))
                expect(branches[1].name).to(equal("master"))
                expect(branches[1].project).to(equal(project))
                expect(branches[1].id).to(equal("project/ngs/sources.ngs.io:master"))
                try! realm.write { realm.deleteAll() }
            }
        }
    }
}