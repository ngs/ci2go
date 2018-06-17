//
//  Section.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

protocol Sectionable: Comparable & Equatable {
    associatedtype Element: Comparable & Equatable
    var sectionTitle: String? { get }
    var sectionComparable: Element { get }
}

struct Section<T: Sectionable> {
    let items: [T]
    var title: String? {
        return items.first?.sectionTitle
    }
    var comparable: T.Element? {
        return items.first?.sectionComparable
    }
}

extension Section: Comparable {
    static func < (lhs: Section<T>, rhs: Section<T>) -> Bool {
        guard
            let l = lhs.comparable,
            let r = rhs.comparable else {
                return false
        }
        return l < r
    }
}

extension Section: Equatable {
    static func == (lhs: Section<T>, rhs: Section<T>) -> Bool {
        guard
            let l = lhs.comparable,
            let r = rhs.comparable else {
                return false
        }
        return l == r
    }
}

typealias Sections<T: Sectionable> = [Section<T>]
