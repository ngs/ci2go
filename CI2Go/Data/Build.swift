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
    let user: User?
    let status: Status
    let lifecycle: Lifecycle
    let project: Project
    let queuedAt: Date?
    let branch: Branch?
    let vcsRevision: String?
    let parallelCount: Int
    let configuration: String
    let isPlatformV2: Bool
    let hasArtifacts: Bool
    
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
        case branchName = "branch"
        case vcsRevision = "vcs_revision"
        case user = "user"
        case parallelCount = "parallel"
        case configuration = "circle_yml"
        case platform = "platform"
        case hasArtifacts = "has_artifacts"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        project = try Project(from: decoder)
        number = try values.decode(Int.self, forKey: .number)
        vcsRevision = try? values.decode(String.self, forKey: .vcsRevision)
        lifecycle = try values.decode(Lifecycle.self, forKey: .lifecycle)
        outcome = (try? values.decode(Outcome.self, forKey: .outcome)) ?? .invalid
        hasArtifacts = (try? values.decode(Bool.self, forKey: .hasArtifacts)) ?? false
        status = try values.decode(Status.self, forKey: .status)
        user = try? values.decode(User.self, forKey: .user)
        queuedAt = try? values.decode(Date.self, forKey: .queuedAt)
        let config = (try? values.decode([String: String].self, forKey: .configuration)) ?? [:]
        configuration = config["string"] ?? ""
        isPlatformV2 = ((try? values.decode(String.self, forKey: .platform)) ?? "") == "2.0"
        parallelCount = (try? values.decode(Int.self, forKey: .parallelCount)) ?? 1
        if let compareURLStr = (try? values.decode(String.self, forKey: .compareURL))?
            .replacingOccurrences(of: "^", with: "") {
            compareURL = URL(string: compareURLStr)
        } else {
            compareURL = nil
        }
        buildParameters = (try? values.decode(BuildParameters.self, forKey: .compareURL)) ??
            BuildParameters()
        steps = (try? values.decode([BuildStep].self, forKey: .steps)) ?? []
        let commits = (try? values.decode([Commit].self, forKey: .commits)) ?? []
        var body = (try? values.decode(String.self, forKey: .body)) ?? ""
        if let subject = commits.first?.subject, body.isEmpty {
            body = subject
        }
        if let branchName = try? values.decode(String.self, forKey: .branchName) {
            branch = Branch(project, branchName)
        } else {
            branch = nil
        }
        let workflow = try? values.decode(Workflow.self, forKey: .workflow)
        jobName = (try? values.decode(String.self, forKey: .jobName)) ?? workflow?.jobName
        self.body = body
        self.commits = commits
        self.workflow = workflow
    }

    init(project: Project, number: Int, status: Status = .notRun) {
        self.project = project
        self.number = number
        self.status = status
        compareURL = nil
        buildParameters = [:]
        steps = []
        commits = []
        body = ""
        jobName = nil
        workflow = nil
        queuedAt = nil
        branch = nil
        outcome = .invalid
        lifecycle = .notRun
        vcsRevision = nil
        user = nil
        parallelCount = 1
        configuration = ""
        isPlatformV2 = false
        hasArtifacts = false
    }

    init(build: Build, newSteps: [BuildStep]) {
        project = build.project
        number = build.number
        status = build.status
        compareURL = build.compareURL
        buildParameters = build.buildParameters
        steps = newSteps
        commits = build.commits
        body = build.body
        jobName = build.jobName
        workflow = build.workflow
        queuedAt = build.queuedAt
        branch = build.branch
        outcome = build.outcome
        lifecycle = build.lifecycle
        vcsRevision = build.vcsRevision
        user = build.user
        parallelCount = build.parallelCount
        configuration = build.configuration
        isPlatformV2 = build.isPlatformV2
        hasArtifacts = build.hasArtifacts
    }

    func build(withNewActionStatus status: BuildAction.Status, in nodeIndex:  Int, step: Int) -> Build {
        let newSteps = steps.map { buildStep -> BuildStep in
            let actions = buildStep.actions.map { action -> BuildAction in
                if action.index == nodeIndex && action.step == step {
                    return BuildAction(action: action, newStatus: status)
                }
                return action
            }
            return BuildStep(name: buildStep.name, actions: actions)
        }
        return Build(build: self, newSteps: newSteps)
    }

    var apiPath: String {
        return "\(project.apiPath)/\(number)"
    }

    var timestamp: Date? {
        return queuedAt ?? commits.first?.authorDate
    }

    var hasWorkflows: Bool {
        return workflow?.name.isEmpty == false && workflow?.jobName.isEmpty == false
    }

    var pusherChannelNamePrefix: String {
        // private-ngs@ci2go@494@vcs-github
        return "private-\(project.username)@\(project.name)@\(number)@vcs-\(project.vcs.rawValue)"
    }

    var pusherChannelNames: [String] {
        var names: [String] = [
            pusherChannelNamePrefix,
            "\(pusherChannelNamePrefix)@all"
        ]
        for i in 0..<parallelCount {
            names.append("\(pusherChannelNamePrefix)@\(i)")
        }
        return names
    }

    var configurationName: String {
        return isPlatformV2 ? ".circleci/config.yml" : "circle.yml"
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

extension Build: Equatable {
    static func == (lhs: Build, rhs: Build) -> Bool {
        return lhs.apiPath == rhs.apiPath && lhs.status == rhs.status
    }
}

