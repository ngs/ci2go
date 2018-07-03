//
//  FileKitExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/04.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import FileKit

extension File {
    var modifiedDate: Date? {
        let ret = try? path.url.resourceValues(forKeys: [.contentModificationDateKey])
        return ret?.contentModificationDate
    }
}
