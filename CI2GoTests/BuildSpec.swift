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
            expect(build.previsousBuild?.number).to(equal(203))
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
                expect(realm.objects(Build).count).to(equal(2))
                expect(realm.objects(Project).count).to(equal(1))
                expect(realm.objects(Branch).count).to(equal(1))
                expect(realm.objects(User).count).to(equal(1))
                expect(realm.objects(BuildStep).count).to(equal(0))
                expect(realm.objects(Build)[0].number).to(equal(204))
                expect(realm.objects(Build)[1].number).to(equal(203))
                itBehavesLike("Mapped Build")
            }
            it("maps detailed JSON") {
                let json = fixtureJSON("build.json", self.dynamicType)
                try! realm.write {
                    realm.add(Mapper<Build>().map(json)!, update: true)
                    realm.add(Mapper<Build>().map(json)!, update: true)
                }
                expect(realm.objects(Commit).count).to(equal(1))
                expect(realm.objects(Build).count).to(equal(3))
                expect(realm.objects(Project).count).to(equal(1))
                expect(realm.objects(User).count).to(equal(1))
                expect(realm.objects(Branch).count).to(equal(1))
                expect(realm.objects(BuildStep).count).to(equal(39))
                expect(realm.objects(BuildAction).count).to(equal(39))
                expect(realm.objects(Build)[0].number).to(equal(204))
                expect(realm.objects(Build)[1].number).to(equal(203))

                itBehavesLike("Mapped Build")

                let build = realm.objects(Build).first!

                let names = [
                    "Starting the build",
                    "Start container",
                    "Enable SSH",
                    "Restore source cache",
                    "Checkout using deploy key: 32:17:da:da:42:6a:54:65:bf:ec:4c:90:5b:74:67:0c",
                    "Configure the build",
                    "Exporting env vars from circle.yml",
                    "Exporting env vars from project settings",
                    "Select Xcode Version",
                    "Restore cache",
                    "curl https://github.com/ngs.keys >> ~/.ssh/authorized_keys",
                    "sudo pip install awscli",
                    "sudo gem update bundler",
                    "export TGZ=\"$(cat Gemfile | md5).tgz\"; (aws s3 cp s3://$S3_BUCKET/deps/rubygems/$TGZ $TGZ && tar xvfz $TGZ) || true",
                    "export TGZ=\"$(cat Podfile | md5).tgz\"; (aws s3 cp s3://$S3_BUCKET/deps/cocoapods/$TGZ $TGZ && tar xvfz $TGZ) || true",
                    "export TGZ=\"$(cat Gemfile | md5).tgz\"; bundle check --path=vendor/bundle || (bundle install -j4 --path=vendor/bundle && tar cvfz $TGZ vendor/bundle && aws s3 cp $TGZ s3://$S3_BUCKET/deps/rubygems/$TGZ)",
                    "export TGZ=\"$(cat Podfile | md5).tgz\"; [ -f $TGZ ] || bundle exec pod check || (bundle exec pod install && tar cvfz $TGZ Pods && aws s3 cp $TGZ s3://$S3_BUCKET/deps/cocoapods/$TGZ)",
                    "/usr/libexec/PlistBuddy 'Pods/Target Support Files/Pods-CI2Go WatchKit App Extension-RxSwift/Info.plist' -c 'Set :CFBundleShortVersionString 2.0.0'",
                    "/usr/libexec/PlistBuddy 'Pods/Target Support Files/Pods-CI2Go WatchKit App Extension-RxCocoa/Info.plist' -c 'Set :CFBundleShortVersionString 2.0.0'",
                    "/usr/libexec/PlistBuddy 'Pods/Target Support Files/Pods-CI2Go WatchKit App Extension-RxBlocking/Info.plist' -c 'Set :CFBundleShortVersionString 2.0.0'",
                    "/usr/libexec/PlistBuddy 'Pods/Target Support Files/Pods-CI2Go-RxSwift/Info.plist' -c 'Set :CFBundleShortVersionString 2.0.0'",
                    "/usr/libexec/PlistBuddy 'Pods/Target Support Files/Pods-CI2Go-RxCocoa/Info.plist' -c 'Set :CFBundleShortVersionString 2.0.0'",
                    "/usr/libexec/PlistBuddy 'Pods/Target Support Files/Pods-CI2Go-RxBlocking/Info.plist' -c 'Set :CFBundleShortVersionString 2.0.0'",
                    "echo 'export PATH=$HOME/$CIRCLE_PROJECT_REPONAME/vendor/bundle/ruby/2.0.0/bin:$PATH' >> ~/.bashrc",
                    "echo \"export KEYCHAIN_PASSWORD=$(ruby -rsecurerandom -e 'print SecureRandom.hex')\" >> ~/.bashrc",
                    "echo \"export FL_UNLOCK_KEYCHAIN_PASSWORD=$KEYCHAIN_PASSWORD\" >> ~/.bashrc",
                    "bundle exec fastlane import_certs",
                    "bundle exec sigh download_all -o fastlane/profiles",
                    "Save cache",
                    "bundle exec scan --workspace CI2Go.xcworkspace --scheme CI2Go --device 'iPhone 6s'",
                    "mkdir -p $CIRCLE_TEST_REPORTS/junit && cat fastlane/test_output/report.junit > $CIRCLE_TEST_REPORTS/junit/report.xml",
                    "Checking deployment",
                    "Checking deployment",
                    "bundle exec fastlane build_adhoc",
                    "bundle exec fastlane deploy_s3 > /dev/null 2>&1",
                    "Collect test metadata",
                    "Collect artifacts",
                    "Ensure caches are uploaded",
                    "Disable SSH"
                ]
                expect(build.steps.map({ $0.name })).to(equal(names))
                expect(build.steps.map({ $0.index })).to(equal([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38]))
                expect(build.steps.map({ $0.actions.count })).to(equal([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]))
                expect(build.steps.map({ $0.actions.first!.name })).to(equal(names))

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
                            expect(realm.objects(Build).count).to(equal(27))
                            let ar = realm.objects(Build).map { $0.id }
                            expect(ar).to(equal([
                                "project/ngs/ci2go/204",
                                "project/ngs/ci2go/203",
                                "project/ngs/ci2go/200",
                                "project/ngs/ci2go/199",
                                "project/ngs/ci2go/198",
                                "project/ngs/ci2go/197",
                                "project/ngs/ci2go/196",
                                "project/ngs/ci2go/195",
                                "project/ngs/ci2go/194",
                                "project/ngs/ci2go/193",
                                "project/ngs/ci2go/192",
                                "project/ngs/ci2go/191",
                                "project/ngs/ci2go/189",
                                "project/ngs/ci2go/190",
                                "project/ngs/ci2go/187",
                                "project/ngs/ci2go/186",
                                "project/ngs/ci2go/185",
                                "project/ngs/ci2go/180",
                                "project/ngs/ci2go/184",
                                "project/ngs/ci2go/181",
                                "project/ngs/ci2go/183",
                                "project/ngs/ci2go/24",
                                "project/ngs/ci2go/182",
                                "project/ngs/ci2go/179",
                                "project/ngs/ci2go/178",
                                "project/ngs/ci2go/175",
                                "project/ngs/ci2go/174"]))
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
