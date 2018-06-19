//
//  DateDecoder.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/20.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct DateDecoder {
    static let dateFormats = [
        // 2018-06-19T06:29:50.030Z
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        // 2018-06-19T15:29:08+09:00
        "yyyy-MM-dd'T'HH:mm:ssXXXXX"
    ]

    static func decode(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        for format in dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateStr) {
                return date
            }
        }
        throw DateError.invalidDate
    }
}
