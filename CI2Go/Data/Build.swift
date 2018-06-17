//
//  Build.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Build: Decodable, EndpointConvertable {
    typealias BuildParameters = [String: String]
    
    let number: Int
    let compareURL: URL?
    let buildParameters: BuildParameters
    let steps: [BuildStep]
    let commits: [Commit]
    let body: String
    let jobName: String?
    let workflow: Workflow?
    let outcome: Outcome
    let status: Status
    let lifecycle: Lifecycle
    let project: Project
    let queuedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case number = "build_num"
        case compareURL = "compare"
        case buildParameters = "build_parameters"
        case steps
        case commits = "all_commit_details"
        case body
        case workflow = "workflows"
        case jobName = "job_name"
        case status
        case outcome
        case lifecycle
        case queuedAt = "queued_at"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        project = try Project(from: decoder)
        number = try values.decode(Int.self, forKey: .number)
        lifecycle = try values.decode(Lifecycle.self, forKey: .lifecycle)
        outcome = (try? values.decode(Outcome.self, forKey: .outcome)) ?? .invalid
        status = try values.decode(Status.self, forKey: .status)
        queuedAt = try? values.decode(Date.self, forKey: .queuedAt)
        let compareURLStr = (try values.decode(String.self, forKey: .compareURL))
            .replacingOccurrences(of: "^", with: "")
        compareURL = URL(string: compareURLStr)
        buildParameters = (try? values.decode(BuildParameters.self, forKey: .compareURL)) ??
            BuildParameters()
        steps = (try? values.decode([BuildStep].self, forKey: .steps)) ?? []
        let commits = (try? values.decode([Commit].self, forKey: .commits)) ?? []
        var body = (try? values.decode(String.self, forKey: .body)) ?? ""
        if let subject = commits.first?.subject, body.isEmpty {
            body = subject
        }
        let workflow = try? values.decode(Workflow.self, forKey: .workflow)
        jobName = (try? values.decode(String.self, forKey: .jobName)) ?? workflow?.jobName
        self.body = body
        self.commits = commits
        self.workflow = workflow
    }

    init(project: Project, number: Int) {
        self.project = project
        self.number = number
        compareURL = nil
        buildParameters = [:]
        steps = []
        commits = []
        body = ""
        jobName = nil
        workflow = nil
        queuedAt = nil
        outcome = .invalid
        status = .notRun
        lifecycle = .notRun
    }

    var apiPath: String {
        return "\(project.apiPath)/\(number)"
    }
}

extension Build: Equatable {
    static func == (lhs: Build, rhs: Build) -> Bool {
        return lhs.apiPath == rhs.apiPath
    }
}

extension Build: Comparable {
    static func < (lhs: Build, rhs: Build) -> Bool {
        if
            let lq = lhs.queuedAt,
            let rq = rhs.queuedAt {
            return lq < rq
        }
        if lhs.project == rhs.project {
            return lhs.number < rhs.number
        }
        if
            let lq = lhs.commits.first?.authorDate,
            let rq = rhs.commits.first?.authorDate {
            return lq < rq
        }
        return false
    }
}
