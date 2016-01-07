//
//  Build.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/7/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import Carlos
import WatchConnectivity

#if os(watchOS)
    typealias Build = BuildCompact
#endif

class BuildCompact: Mappable {
    static let cache = MemoryCacheLevel<String, NSString>() >>> DiskCacheLevel()
    static let cacheKey = "compactBuilds"

    var id = ""
    var rawStatus: String?
    var projectPath = ""
    var number = ""
    var branchName = ""
    var commitSubject = ""
    var startedAt = ""
    var userName = ""

    var status: Build.Status? {
        guard let rawStatus = rawStatus else {
            return nil
        }
        return Build.Status(rawValue: rawStatus)
    }

    class func fromCache(callback: ([BuildCompact]) -> Void) {
        let cache = self.cache.get(cacheKey)
        cache.onSuccess { str in
            if let res = Mapper<BuildCompact>().mapArray(str) {
                callback(res)
            }
        }
    }

    class func setCache(list: [BuildCompact]) {
        if let json = Mapper<BuildCompact>().toJSONString(list) {
            self.cache.set(json, forKey: cacheKey)
        }
    }

    class func fromCache(id: String, _ callback: (BuildCompact) -> Void) {
        fromCache { builds in
            if let found = builds.filter({ $0.id == id }).first {
                callback(found)
            }
        }
    }

    class func requestList(callback: ([BuildCompact]) -> Void) {
        fromCache { builds in
            callback(builds)
        }
        let session = WCSession.defaultSession()
        session.sendMessage(
            CI2GoWatchConnectivityFunction.RequestBuilds.toMessage(),
            replyHandler: { res in
                if let json = res[kCI2GoWatchConnectivityBuildsKey] as? [[String: AnyObject]]
                    , ar = Mapper<BuildCompact>().mapArray(json) {
                        callback(ar)
                        setCache(ar)
                }
            }, errorHandler: nil)
    }

    required init?(_ map: Map) {}
    func mapping(map: Map) {
        id <- map["id"]
        rawStatus <- map["status"]
        projectPath <- map["projectPath"]
        number <- map["number"]
        branchName <- map["branchName"]
        commitSubject <- map["commitSubject"]
        startedAt <- map["startedAt"]
    }
}
