//
//  StringFirstStringExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/3/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation

extension String {
    var firstString: String {
        guard let fchar = characters.first else { return "" }
        return String(fchar)
    }
    var humanize: String {
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