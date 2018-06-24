//
//  Build+Cache.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/24.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import FileKit
import Foundation

extension Array where Element == Build {
    static var cacheFile: TextFile {
        return TextFile(path: Path.userDocuments + "/project.json")
    }

    static func fromCache() -> [Build]? {
        let jsonDecoder = JSONDecoder()
        guard
            let jsonString = try? cacheFile.read(),
            let data = jsonString.data(using: .utf8)
            else { return nil }
        jsonDecoder.dateDecodingStrategy = .custom({ try DateDecoder.decode($0) })
        return try? jsonDecoder.decode(self, from: data)
    }
}
