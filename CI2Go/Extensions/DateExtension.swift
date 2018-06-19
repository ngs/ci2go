//
//  DateExtension.swift
//  Grabbed from https://gist.github.com/minorbug/468790060810e0d29545#gistcomment-2272953
//
//  Created by Atsushi Nagase on 2018/06/19.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension Date {
    fileprivate struct Item {
        let multi: String
        let single: String
        let last: String
        let value: Int?
    }

    fileprivate var components: DateComponents {
        return Calendar.current.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month, .year, .second],
            from: self,
            to: Calendar.current.date(byAdding: .second, value: -1, to: Date())!
        )
    }

    fileprivate var items: [Item] {
        return [
            Item(multi: "years ago", single: "1 year ago", last: "Last year", value: components.year),
            Item(multi: "months ago", single: "1 month ago", last: "Last month", value: components.month),
            Item(multi: "weeks ago", single: "1 week ago", last: "Last week", value: components.weekday),
            Item(multi: "days ago", single: "1 day ago", last: "Last day", value: components.day),
            Item(multi: "minutes ago", single: "1 minute ago", last: "Last minute", value: components.minute),
            Item(multi: "seconds ago", single: "Just now", last: "Last second", value: components.second)
        ]
    }

    public var timeAgoSinceNow: String {
        return timeAgo()
    }

    public func timeAgo(numericDates: Bool = false) -> String {
        for item in items {
            switch (item.value, numericDates) {
            case let (.some(step), _) where step == 0:
                continue
            case let (.some(step), true) where step == 1:
                return item.last
            case let (.some(step), false) where step == 1:
                return item.single
            case let (.some(step), _):
                return String(step) + " " + item.multi
            default:
                continue
            }
        }

        return "Just now"
    }
}
