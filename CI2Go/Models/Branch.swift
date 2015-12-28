//
//  Branch.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 12/28/15.
//  Copyright © 2015 LittleApps Inc. All rights reserved.
//

import RealmSwift

class Branch: Object {
    dynamic var id: String = ""
    var apiPath: String {
        return "/branch"
    }
}
