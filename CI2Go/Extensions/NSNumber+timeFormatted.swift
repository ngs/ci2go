//
//  NSNumber+timeFormatted.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation

extension NSNumber {
  public var timeFormatted: String {
    var val = self.doubleValue / 1000
    let hours = Int(floor(val / 3600))
    let minutes = Int(floor(val % 3600 / 60))
    let seconds = Int(floor(val % 60))
    if hours > 0 {
      return NSString(format: "%d:%02d:%02d", hours, minutes, seconds) as String
    }
    return NSString(format: "%02d:%02d", minutes, seconds) as String
  }
}
