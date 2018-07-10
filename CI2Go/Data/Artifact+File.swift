//
//  Artifact+File.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import FileKit

extension Artifact {
    var localPath: Path {
        if
            let iCloudRoot = FileManager.default.url(forUbiquityContainerIdentifier: nil),
            let iCloudPath = Path(url: iCloudRoot) {
            return iCloudPath + "Documents/Artifacts/\(downloadURL.host ?? "localhost")/\(downloadURL.path)"
        }
        return Path.userDocuments + "Artifacts/\(downloadURL.host ?? "localhost")/\(downloadURL.path)"
    }

    var progressFilePath: Path {
        return localPath.parent + ".\(localPath.fileName).progress"
    }

    var isInProgress: Bool {
        return progressFilePath.exists
    }

    func unlinkProgressFile() throws {
        try progressFilePath.deleteFile()
    }

    func createProgressFile() throws {
        try progressFilePath.parent.createDirectory(withIntermediateDirectories: true)
        try progressFilePath.createFile()
    }
}
