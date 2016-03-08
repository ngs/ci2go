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
    dynamic var project: Project?
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
    dynamic var vcsType: String = "github"

    let commits = List<Commit>()
    let retries = List<Build>()
    let steps = List<BuildStep>()

    var pusherChannelName: String? {
        guard let repoUser = project?.username, repoName = project?.repositoryName where number > 0
            else {
            return nil
        }
        return "private-\(repoUser)@\(repoName)@\(number)@vcs-\(vcsType)"
    }

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
        , previsousBuild: Build?
        , previsousSuccessfulBuild: Build?
        , queuedAt: NSDate?
        , usageQueuedAt: NSDate?
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
        vcsType <- map["vcs_type"]
        queuedAt <- (map["queued_at"], JSONDateTransform())
        usageQueuedAt <- (map["usage_queued_at"], JSONDateTransform())
        commits <- map["all_commit_details"]
        branchName <- map["branch"]
        previsousBuild <- map["previous"]
        previsousSuccessfulBuild <- map["previous_successful_build"]
        vcsRevision <- map["vcs_revision"]
        steps <- map["steps"]
        node <- map["node"]
        previsousBuild?.project = project
        previsousBuild?.updateId()
        previsousSuccessfulBuild?.project = project
        previsousSuccessfulBuild?.updateId()
        if previsousSuccessfulBuild?.id.isEmpty == false && previsousSuccessfulBuild?.branch != nil {
            previsousSuccessfulBuild?.branch?.project = self.project
            self.previsousSuccessfulBuild = previsousSuccessfulBuild
        }
        if previsousBuild?.id.isEmpty == false &&
            previsousBuild?.branch != nil {
                previsousBuild?.branch?.project = self.project
                if previsousBuild?.id.isEmpty == false {
                    self.previsousBuild = previsousBuild
                }
        }
        if let branchName = branchName where !branchName.isEmpty {
            let branch = Branch()
            branch.name = branchName
            branch.project = self.project
            branch.updateId()
            if !branch.id.isEmpty {
                self.branch = branch
            }
        }
        if let triggeredCommit = Commit(map) {
            triggeredCommit.branch = branch
            triggeredCommit.project = project
            triggeredCommit.updateId()
            commits.append(triggeredCommit)
            self.triggeredCommit = triggeredCommit
        }
        self.queuedAt = queuedAt ?? usageQueuedAt
        self.commits.removeAll()
        commits.forEach { c in
            c.project = self.project
            c.branch?.project = self.project
            c.branch?.updateId()
            c.updateId()
            if !self.commits.contains(c) {
                self.commits.append(c)
            }
        }
        var index = 0
        var sectionIndex = 0
        var currentSectionType: String?
        steps.forEach { c in
            guard let actionType = c.actions.first?.actionType else { return }
            currentSectionType = currentSectionType ?? actionType
            c.build = self
            c.index = index++
            c.actions.forEach { a in
                a.buildStep = c
            }
            c.updateId()
            if currentSectionType != actionType {
                sectionIndex++
                currentSectionType = actionType
            }
            if !self.steps.contains(c) {
                self.steps.append(c)
            }
        }
        updateId()
    }

    func updateId() {
        if let apiPath = apiPath {
            id = apiPath
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["lifecycle", "status", "outcome", "URL", "compareURL", "apiPath", "pusherChannelName"]
    }

    func dup(target: Build? = nil) -> Build {
        let dup = target ?? Build()
        dup.branch = branch
        dup.buildParametersData = buildParametersData
        dup.circleYAML = circleYAML
        dup.compareURLString = compareURLString
        dup.dontBuild = dontBuild
        dup.id  = id
        dup.sshEnabled  = sshEnabled
        dup.hasArtifacts  = hasArtifacts
        dup.number = number
        dup.parallelCount = parallelCount
        dup.project = project
        dup.rawLifecycle = rawLifecycle
        dup.rawStatus = rawStatus
        dup.rawOutcome = rawOutcome
        dup.retryOf = retryOf
        dup.previsousBuild = previsousBuild
        dup.previsousSuccessfulBuild = previsousSuccessfulBuild
        dup.timeMillis = timeMillis
        dup.triggeredCommit = triggeredCommit
        dup.urlString = urlString
        dup.user = user
        dup.why = why
        dup.queuedAt = queuedAt
        dup.startedAt = startedAt
        dup.stoppedAt = stoppedAt
        dup.node = node
        dup.steps.removeAll()
        dup.steps.appendContentsOf(steps)
        dup.updateId()
        return dup
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