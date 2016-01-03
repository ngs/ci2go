//
//  DictionaryExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/3/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation

extension Dictionary {
    var query: String {
        let comps = NSURLComponents()
        var queryItems: [NSURLQueryItem] = []
        for (n, v) in self {
            if var str = v as? String {
                str = str.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                queryItems.append(NSURLQueryItem(name: "\(n)", value: str))
            } else {
                queryItems.append(NSURLQueryItem(name: "\(n)", value: "\(v)"))
            }
        }
        comps.queryItems = queryItems
        return comps.query ?? ""
    }
}