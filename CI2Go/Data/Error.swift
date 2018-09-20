//
//  Error.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/19.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

enum APIError: Error {
    case noData
    case notLoggedIn
}

enum JSError: Error {
    case caught(String)
}

enum DateError: String, Error {
    case invalidDate
}
