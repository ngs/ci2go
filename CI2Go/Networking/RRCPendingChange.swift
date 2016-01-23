//
//  RRCPendingChange.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/24/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import RealmResultsController

struct RRCPendingChange {
    let sectionIndex: Int?
    let oldIndexPath: NSIndexPath?
    let newIndexPath: NSIndexPath?
    let changeType: RealmResultsChangeType
}