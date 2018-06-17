//
//  BuildStep.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct BuildStep: Decodable {
    let actions: [BuildAction]
    let name: String
}
