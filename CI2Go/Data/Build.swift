//
//  Build.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Build: Decodable {
    typealias BuildParameters = [String: String]
    
    let number: Int
    let compareURL: URL?
    let buildParameters: BuildParameters
    let isOSS: Bool
    let steps: [BuildStep]
    let commits: [Commit]
    let body: String
    let jobName: String?
    let workflow: Workflow?
    let outcome: Outcome
    let status: Status
    let lifecycle: Lifecycle
    
    enum CodingKeys: String, CodingKey {
        case number = "build_num"
        case compareURL = "compare"
        case buildParameters = "build_parameters"
        case isOSS = "oss"
        case steps
        case commits = "all_commit_details"
        case body
        case workflow = "workflows"
        case jobName = "job_name"
        case status
        case outcome
        case lifecycle
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        number = try values.decode(Int.self, forKey: .number)
        lifecycle = try values.decode(Lifecycle.self, forKey: .lifecycle)
        outcome = (try? values.decode(Outcome.self, forKey: .outcome)) ?? .invalid
        status = try values.decode(Status.self, forKey: .status)
        let compareURLStr = (try values.decode(String.self, forKey: .compareURL))
            .replacingOccurrences(of: "^", with: "")
        compareURL = URL(string: compareURLStr)
        buildParameters = (try? values.decode(BuildParameters.self, forKey: .compareURL)) ??
            BuildParameters()
        isOSS = (try? values.decode(Bool.self, forKey: .isOSS)) ?? false
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
}

