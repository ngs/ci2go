//
//  ArrayExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension Array where Element: Equatable & Comparable {
    @discardableResult mutating func merge(elements: [Element], in section: Int = 0) -> CollectionChanges {
        var changes = CollectionChanges()
        let original = self
        elements.forEach { element in
            if let i = index(of: element), let _ = original.index(of: element) {
                changes.append(.updateRows([IndexPath(row: i, section: section)]))
                return
            }
            var i = 0
            while i < count && self[i] < element {
                i += 1
            }
            insert(element, at: i)
            changes.append(.insertRows([IndexPath(row: i, section: section)]))
        }
        return changes
    }
}

extension Array {
    @discardableResult mutating func merge<T>(elements: [T]) -> CollectionChanges where Element == Section<T> {
        var changes = CollectionChanges()
        elements.forEach { element in
            if let i = filter({ $0.comparable != nil })
                .map({ $0.comparable! })
                .index(of: element.sectionComparable) {
                var items = self[i].objects
                let res = items.merge(elements: [element], in: i)
                self[i] = Section(objects: items)
                changes.append(contentsOf: res)
                return
            }
            var i = 0
            while i < count && self[i].comparable! < element.sectionComparable {
                i += 1
            }
            insert(Section(objects: [element]), at: i)
            changes.append(.insertSections(IndexSet([i])))
        }
        return changes
    }

    func numberOfObjects<T>(in section: Int) -> Int where Element == Section<T> {
        return self[section].objects.count
    }

    func object<T>(at indexPath: IndexPath) -> T where Element == Section<T> {
        return self[indexPath.section].objects[indexPath.row]
    }
}


extension Array where Element: Sectionable {
    var sectionized: Sections<Element> {
        var ret = Sections<Element>()
        ret.merge(elements: self)
        return ret
    }
}
