//
//  StringExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension String {
    var humanize: String {
        let words = components(separatedBy: "_")
        var ret = [String]()
        for word in words {
            guard let firstChar = word.first else { continue }
            let remainingChars = word.dropFirst()
            let w = String(firstChar).uppercased() + String(remainingChars)
            ret.append(w)
        }
        return ret.joined(separator: " ")
    }
}
