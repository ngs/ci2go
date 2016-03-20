//
//  PathWeblocExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 3/21/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import FileKit

extension Path {
    var webLocationFile: Path {
        return pathWithExtensionSuffix(kCI2GoWeblocExtension)
    }

    var webLocation: NSURL? {
        guard webLocationFile.exists else { return nil }
        do {
            let urlStr = try String(contentsOfPath: webLocationFile)
            return NSURL(string: urlStr)
        } catch {
            return nil
        }
    }

    func setWebLocation(url: NSURL?) throws {
        if let str = url?.absoluteString {
            try str |> TextFile(path: webLocationFile, encoding: NSUTF8StringEncoding)
        } else {
            try webLocationFile.deleteFile()
        }
    }

    func pathWithExtensionSuffix(suffix: String) -> Path {
        return parent + ".\(fileName).\(suffix)"
    }
}
