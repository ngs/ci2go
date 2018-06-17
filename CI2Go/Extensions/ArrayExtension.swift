//
//  ArrayExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension Array where Element: Equatable & Comparable {
    mutating func merge(elements: [Element]) -> CollectionChanges {
        var changes = CollectionChanges()
        elements.forEach { element in
            if let i = index(of: element) {
                changes.append(.updateRows([IndexPath(row: i, section: 0)]))
                return
            }
            var i = 0
            while i < count && self[i] < element {
                i += 1
            }
            insert(element, at: i)
            changes.append(.insertRows([IndexPath(row: i, section: 0)]))
        }
        return changes
    }
}

