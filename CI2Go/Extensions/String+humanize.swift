//
//  String+humanize.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation

extension String {
  public var humanize: String {
    get {
      let words = componentsSeparatedByString("_")
      var ret = [String]()
      for word in words {
        let firstChar = word.substringToIndex(startIndex.advancedBy(1)).uppercaseString
        let remainingChars = word.substringFromIndex(startIndex.advancedBy(1))
        let w = firstChar + remainingChars
        ret.append(w)
      }
      return ret.joinWithSeparator(" ")
    }
  }
}