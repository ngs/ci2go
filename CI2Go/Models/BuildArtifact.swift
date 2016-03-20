//
//  BuildArtifact.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 3/21/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper
import FileKit

class BuildArtifact: Object, Mappable {
    dynamic var build: Build?
    dynamic var path = ""
    dynamic var prettyPath = ""
    dynamic var nodeIndex = 0
    dynamic var urlString = ""
    dynamic var localPathString = ""

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    func mapping(map: Map) {
        path <- map["path"]
        prettyPath <- map["pretty_path"]
        nodeIndex <- map["node_index"]
        urlString <- map["url"]
        let fileManager = NSFileManager.defaultManager()
        let documentsUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        let filePath = url.path!
        localPathString = (Path(documentsUrl.path!) + ".\(filePath)").resolved.URL.path!
    }

    func dup(target: BuildArtifact? = nil) -> BuildArtifact {
        let dup = target ?? BuildArtifact()
        dup.path = path
        dup.prettyPath = prettyPath
        dup.nodeIndex = nodeIndex
        dup.urlString = urlString
        dup.localPathString = localPathString
        return dup
    }

    override class func primaryKey() -> String {
        return "urlString"
    }

    override static func ignoredProperties() -> [String] {
        return ["url", "localPath"]
    }

    var url: NSURL {
        return NSURL(string: urlString)!
    }

    var localPath: Path {
        return Path(localPathString)
    }

    var webLocationFilePath: Path {
        let l = localPath
        return l.parent + ".\(l.fileName).\(kCI2GoWeblocExtension)"
    }

    var browseEntryPointPath: Path {
        var ret = localPath
        while ret.fileName != "artifacts" && ret.components.count > 0 {
            ret = ret.parent
        }
        return ret.resolved
    }

}
