//
//  BuildAction.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxBlocking
import ObjectMapper
import Carlos

class BuildAction: Object, Mappable, Equatable, Comparable {
    enum Status: String {
        case Success = "success"
        case Failed = "failed"
        case Canceled = "canceled"
        case Timedout = "timedout"
        case Running = "running"
    }
    dynamic var bashCommand = ""
    dynamic var buildStep: BuildStep? {
        didSet { updateId() }
    }
    dynamic var stepNumber: Int = 0
    dynamic var command = ""
    dynamic var endedAt: NSDate?
    dynamic var exitCode: Int = 0
    dynamic var hasOutput = false
    dynamic var id = ""
    dynamic var isCanceled = false
    dynamic var isContinue = false
    dynamic var isFailed = false
    dynamic var isInfrastructureFail = false
    dynamic var isParallel = false
    dynamic var isTimedout = false
    dynamic var isTruncated = false
    dynamic var name = ""
    dynamic var nodeIndex: Int = 0 {
        didSet { updateId() }
    }
    dynamic var outputURLString: String?
    dynamic var runTimeMillis: Int = 0
    dynamic var source = ""
    dynamic var startedAt: NSDate?
    dynamic var rawStatus: String?
    dynamic var type = ""
    dynamic var output = ""

    private let cache = MemoryCacheLevel<NSURL, NSString>() >>> DiskCacheLevel()

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
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

    func mapping(map: Map) {
        isTruncated <- map["truncated"]
        nodeIndex <- map["index"]
        isParallel <- map["parallel"]
        isFailed <- map["failed"]
        isInfrastructureFail <- map["infrastructure_fail"]
        name <- map["name"]
        bashCommand <- map["bash_command"]
        rawStatus <- map["status"]
        isTimedout <- map["timedout"]
        isContinue <- map["continue"]
        type <- map["type"]
        outputURLString <- map["output_url"]
        exitCode <- map["exit_code"]
        isCanceled <- map["canceled"]
        stepNumber <- map["step"]
        runTimeMillis <- map["run_time_millis"]
        hasOutput <- map["has_output"]
        endedAt <- (map["end_time"], JSONDateTransform())
        startedAt <- (map["start_time"], JSONDateTransform())
    }

    func updateId() {
        if let stepId = self.buildStep?.id where stepId.utf8.count > 0 {
            id = "\(stepId)@\(nodeIndex)"
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }

    var outputURL: NSURL? {
        get {
            if let outputURLString = outputURLString {
                return NSURL(string: outputURLString)
            }
            return nil
        }
        set(value) {
            outputURLString = value?.absoluteString
        }
    }

    private var logSource = Variable<String>("")

    var log: Observable<String> {
        let src = self.logSource, cache = self.cache
        guard let outputURL = outputURL else {
            return Observable.never()
        }
        cache.get(outputURL).onSuccess { log in
            src.value = log as String
        }
        return Observable.combineLatest(self.downloadLog(), src.asObservable()) { ($0, $1) }
            .flatMap { downloadedLog, log -> Observable<String> in
                src.value = downloadedLog
                cache.set(downloadedLog, forKey: outputURL)
                return src.asObservable()
        }
    }

    override static func ignoredProperties() -> [String] {
        return ["status", "outputURL", "logSource", "log"]
    }
}

func ==(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id == rhs.id
}

func >(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id > rhs.id
}

func <(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id < rhs.id
}

func >=(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id >= rhs.id
}

func <=(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id <= rhs.id
}
