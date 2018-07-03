//
//  EndpointTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class EndpointTests: XCTestCase {
    var project: Project!
    var build: Build!
    var branch: Branch!

    override func setUp() {
        super.setUp()
        project = Project(vcs: .github, username: "ngs", name: "ci2go")
        build = Build(project: project, number: 123)
        branch = Branch(project, "test")
    }

    func testCancelBuild() {
        let endpoint: Endpoint<Build> = .cancel(build: build)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go/123/cancel")!,
            endpoint.url)
        XCTAssertEqual(.post, endpoint.httpMethod)
    }

    func testFollowProject() {
        let endpoint: Endpoint<Project> = .follow(project: project)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go/follow")!,
            endpoint.url)
        XCTAssertEqual(.post, endpoint.httpMethod)
    }

    func testGetBuild() {
        let endpoint: Endpoint<Build> = .get(build: build)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go/123")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetArtifacts() {
        let endpoint: Endpoint<[Artifact]> = .artifacts(build: build)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go/123/artifacts")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetMe() {
        let endpoint: Endpoint<User> = .me
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/me")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetProjects() {
        let endpoint: Endpoint<[Project]> = .projects
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/projects")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetProjectBuilds() {
        let endpoint: Endpoint<[Build]> = .builds(project: project)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go?offset=0&limit=30")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetProjectBuildsWithParams() {
        let endpoint: Endpoint<[Build]> = .builds(project: project, offset: 20, limit: 50)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go?offset=20&limit=50")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetBranchBuilds() {
        let endpoint: Endpoint<[Build]> = .builds(branch: branch)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go/tree/test?offset=0&limit=30")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetBranchBuildsWithParams() {
        let endpoint: Endpoint<[Build]> = .builds(branch: branch, offset: 20, limit: 50)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go/tree/test?offset=20&limit=50")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetRecentBuilds() {
        let endpoint: Endpoint<[Build]> = .recent
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/recent-builds?offset=0&limit=30")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testGetRecentBuildsWithParams() {
        let endpoint: Endpoint<[Build]> = .recent(offset: 20, limit: 50)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/recent-builds?offset=20&limit=50")!,
            endpoint.url)
        XCTAssertEqual(.get, endpoint.httpMethod)
    }

    func testRetryBuild() {
        let endpoint: Endpoint<Build> = .retry(build: build)
        XCTAssertEqual(
            URL(string: "https://circleci.com/api/v1.1/project/github/ngs/ci2go/123/retry")!,
            endpoint.url)
        XCTAssertEqual(.post, endpoint.httpMethod)
    }

    func testURLRequest() {
        let endpoint: Endpoint<Build> = .retry(build: build)
        let headers = endpoint.urlRequest(with: nil).allHTTPHeaderFields!
        let keys = Array(headers.keys)
        XCTAssertEqual(["Accept"], keys)
        XCTAssertEqual("application/json", headers["Accept"]!)
    }

    func testURLRequestWithToken() {
        let endpoint: Endpoint<Build> = .retry(build: build)
        let headers = endpoint.urlRequest(with: "Foo").allHTTPHeaderFields!
        let keys = Array(headers.keys)
        XCTAssertEqual(["Accept", "Authorization"], keys)
        XCTAssertEqual("application/json", headers["Accept"]!)
        XCTAssertEqual("Basic Rm9vOg==", headers["Authorization"]!)
    }

}
