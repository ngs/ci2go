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
        let realm = setupRealm()
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
                expect(realm.objects(Branch).count).to(equal(1))
                let project = realm.objects(Project).first!
                let branch = realm.objects(Branch).first!
                expect(project.parallelCount).to(equal(1))
                expect(project.repositoryName).to(equal("sources.ngs.io"))
                expect(project.username).to(equal("ngs"))
                expect(project.vcsURL).to(equal(NSURL(string: "https://github.com/ngs/sources.ngs.io")!))
                expect(project.id).to(equal("ngs/sources.ngs.io"))
                expect(project.isOpenSource).to(beTrue())
                expect(project.isFollowed).to(beTrue())
                expect(project.branches.count).to(equal(1))
                expect(project.branches.first!).to(equal(branch))
                expect(branch.name).to(equal("master"))
                expect(branch.project).to(equal(project))
                expect(branch.id).to(equal("project/ngs/sources.ngs.io:master"))
                try! realm.write { realm.deleteAll() }
            }
        }
    }
}