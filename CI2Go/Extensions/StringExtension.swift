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

    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}