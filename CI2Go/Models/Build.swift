//
//  Build.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Build: Object, Mappable, Equatable, Comparable {
    enum Lifecycle: String {
        case Queued = "queued"
        case Scheduled = "scheduled"
        case NotRun = "not_run"
        case NotRunning = "not_running"
        case Running = "running"
        case Finished = "finished"
    }
    enum Status: String {
        case Retried = "retried"
        case Canceled = "canceled"
        case InfrastructureFail = "infrastructure_fail"
        case Timedout = "timedout"
        case NotRun = "not_run"
        case Running = "running"
        case Failed = "failed"
        case Queued = "queued"
        case Scheduled = "scheduled"
        case NotRunning = "not_running"
        case NoTests = "no_tests"
        case Fixed = "fixed"
        case Success = "success"
    }
    enum Outcome: String {
        case Canceled = "canceled"
        case InfrastructureFail = "infrastructure_fail"
        case Timedout = "timedout"
        case Failed = "failed"
        case NoTests = "no_tests"
        case Success = "success"
    }
    dynamic var branch: Branch?
    dynamic var buildParametersData: NSData?
    dynamic var circleYAML: String = ""
    dynamic var compareURLString: String?
    dynamic var dontBuild: String?
    dynamic var id = ""
    dynamic var sshEnabled = false
    dynamic var hasArtifacts = false
    dynamic var number: Int = 0 {
        didSet { updateId() }
    }
    dynamic var parallelCount: Int = 0
    dynamic var project: Project? {
        didSet {
            branch?.project = project
            updateId()
        }
    }
    dynamic var rawLifecycle: String?
    dynamic var rawStatus: String?
    dynamic var rawOutcome: String?
    dynamic var retryOf: Build?
    dynamic var previsousBuild: Build?
    dynamic var previsousSuccessfulBuild: Build?
    dynamic var timeMillis: Int = 0
    dynamic var triggeredCommit: Commit?
    dynamic var urlString: String?
    dynamic var user: User?
    dynamic var why: String = ""
    dynamic var queuedAt: NSDate?
    dynamic var startedAt: NSDate?
    dynamic var stoppedAt: NSDate?
    dynamic var node: Node?

    let commits = List<Commit>()
    let retries = List<Build>()
    let steps = List<BuildStep>()

    var lifecycle: Lifecycle? {
        get {
            if let rawLifecycle = rawLifecycle {
                return Lifecycle(rawValue: rawLifecycle)
            }
            return nil
        }
        set(value) {
            rawLifecycle = value?.rawValue
        }
    }

    var status: Status? {
        get {
            if let rawStatus = rawStatus {
                return Status(rawValue: rawStatus)
            }
            return nil
        }
        set(value) {
            rawStatus = value?.rawValue
        }
    }

    var outcome: Outcome? {
        get {
            if let rawOutcome = rawOutcome {
                return Outcome(rawValue: rawOutcome)
            }
            return nil
        }
        set(value) {
            rawOutcome = value?.rawValue
        }
    }

    var URL: NSURL? {
        if let urlString = urlString {
            return NSURL(string: urlString)
        }
        return nil
    }

    var compareURL: NSURL? {
        if let compareURLString = compareURLString {
            return NSURL(string: compareURLString)
        }
        return nil
    }

    var apiPath: String? {
        if let prjPath = project?.apiPath {
            return "\(prjPath)/\(number)"
        }
        return nil
    }

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
        var commits = [Commit]()
        , steps = [BuildStep]()
        , branchName: String?
        , vcsRevision: String?
        if let project = Project(map) where !project.id.isEmpty {
            self.project = project
        }
        compareURLString <- map["compare"]
        number <- map["build_num"]
        sshEnabled <- map["ssh_enabled"]
        hasArtifacts <- map["has_artifacts"]
        rawStatus <- map["status"]
        rawLifecycle <- map["lifecycle"]
        rawOutcome <- map["outcome"]
        dontBuild <- map["dont_build"]
        timeMillis <- map["build_time_millis"]
        why <- map["why"]
        circleYAML <- map["circle_yml.string"]
        stoppedAt <- (map["stop_time"], JSONDateTransform())
        startedAt <- (map["start_time"], JSONDateTransform())
        queuedAt <- (map["queued_at"], JSONDateTransform())
        commits <- map["all_commit_details"]
        branchName <- map["branch"]
        previsousBuild <- map["previous"]
        previsousSuccessfulBuild <- map["previous_successful_build"]
        vcsRevision <- map["vcs_revision"]
        steps <- map["steps"]
        node <- map["node"]
        previsousBuild?.project = project
        previsousSuccessfulBuild?.project = project

        if let branchName = branchName where !branchName.isEmpty {
            let branch = Branch()
            branch.name = branchName
            branch.project = self.project
            self.branch = branch
        }

        if let _ = vcsRevision, triggeredCommit = Commit(map) {
            commits.append(triggeredCommit)
            self.triggeredCommit = triggeredCommit
        }

        commits.forEach { c in
            c.project = self.project
            if !self.commits.contains(c) {
                self.commits.append(c)
            }
        }
        var index = 0
        steps.forEach { c in
            c.build = self
            c.index = index++
            if !self.steps.contains(c) {
                self.steps.append(c)
            }
        }
    }

    func updateId() {
        if let apiPath = apiPath {
            id = apiPath
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }
}

func ==(lhs: Build, rhs: Build) -> Bool {
    return lhs.id == rhs.id
}

func >(lhs: Build, rhs: Build) -> Bool {
    return lhs.id > rhs.id
}

func <(lhs: Build, rhs: Build) -> Bool {
    return lhs.id < rhs.id
}

func >=(lhs: Build, rhs: Build) -> Bool {
    return lhs.id >= rhs.id
}

func <=(lhs: Build, rhs: Build) -> Bool {
    return lhs.id <= rhs.id
}