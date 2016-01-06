//
//  NSDateExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import ObjectMapper

extension NSDate {
    public class func fromString(string: String) -> NSDate? {
        return formatter().dateFromString(string) ?? formatter2().dateFromString(string)
    }

    public func toString() -> String {
        return NSDate.formatter().stringFromDate(self)
    }

    public func toCompactString() -> String {
        return NSDate.compactFormatter().stringFromDate(self)
    }

    private class func formatter() -> NSDateFormatter {
        let f = NSDateFormatter()
        f.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return f
    }

    private class func formatter2() -> NSDateFormatter {
        let f = NSDateFormatter()
        f.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        return f
    }

    private class func compactFormatter() -> NSDateFormatter {
        let f = NSDateFormatter()
        f.locale = NSLocale(localeIdentifier: "en_US")
        f.dateFormat = "yyyyMMddHHmmss"
        return f
    }
}

public func JSONDateTransform() -> TransformOf<NSDate, String> {
    return TransformOf<NSDate, String>(
        fromJSON: { (value: String?) -> NSDate? in
            return NSDate.fromString(value ?? "")
        }, toJSON: { (value: NSDate?) -> String? in
            return value?.toString()
        }
    )
}