//
//  IntTimeFormattedExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/2/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation

extension Int {
    var timeFormatted: String {
        let val = Double(self) / 1000.0
        let hours = Int(floor(val / 3600.0))
        let minutes = Int(floor(val % 3600.0 / 60.0))
        let seconds = Int(floor(val % 60.0))
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}