//
//  ArrayExtensionTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class ArrayExtensionTests: XCTestCase {
    func testMergeElements() {
        var ar = [2, 3, 4, 5]
        let res = ar.merge(elements: [3, 1, 4, 6])
        XCTAssertEqual([1, 2, 3, 4, 5, 6], ar)
        XCTAssertEqual(4, res.count)
        XCTAssertEqual(.updateRows([IndexPath(row: 1, section: 0)]), res[0])
        XCTAssertEqual(.insertRows([IndexPath(row: 0, section: 0)]), res[1])
        XCTAssertEqual(.updateRows([IndexPath(row: 3, section: 0)]), res[2])
        XCTAssertEqual(.insertRows([IndexPath(row: 5, section: 0)]), res[3])
    }

    struct DummySectionable: Sectionable {
        static func < (lhs: DummySectionable, rhs: DummySectionable) -> Bool {
            return lhs.sectionComparable == rhs.sectionComparable ?
                lhs.number < rhs.number :
                lhs.sectionComparable < rhs.sectionComparable
        }

        static func == (lhs: DummySectionable, rhs: DummySectionable) -> Bool {
            return lhs.sectionComparable == rhs.sectionComparable && lhs.number == rhs.number
        }

        let number: Int
        let section: Int

        var sectionTitle: String? {
            return "Section \(section)"
        }

        var sectionComparable: Int {
            return 100 - section
        }

        typealias Element = Int

        init(_ section: Int, _ number: Int) {
            self.section = section
            self.number = number
        }
    }

    func testMergeSections() {
        var sections = Sections<DummySectionable>()
        var res = sections.merge(elements: [
            DummySectionable(1, 1),
            DummySectionable(2, 1),
            DummySectionable(1, 0),
            ])
        XCTAssertEqual(["Section 2", "Section 1"], sections.map{ $0.title! })
        XCTAssertEqual([1, 2], sections.map{ $0.objects.count })
        XCTAssertEqual([
            [DummySectionable(2, 1)],
            [DummySectionable(1, 0), DummySectionable(1, 1)]
            ], sections.map{ $0.objects })

        XCTAssertEqual(3, res.count)
        XCTAssertEqual(.insertSections(IndexSet([0])), res[0])
        XCTAssertEqual(.insertSections(IndexSet([0])), res[1])
        XCTAssertEqual(.insertRows([IndexPath(row: 0, section: 1)]), res[2])

        res = sections.merge(elements: [
            DummySectionable(1, 2),
            DummySectionable(0, 1),
            DummySectionable(2, 0),
            DummySectionable(1, 1),
            DummySectionable(1, 0),
            ])

        XCTAssertEqual(["Section 2", "Section 1", "Section 0"], sections.map{ $0.title! })
        XCTAssertEqual([2, 3, 1], sections.map{ $0.objects.count })

        XCTAssertEqual(5, res.count)
        XCTAssertEqual(.insertRows([IndexPath(row: 2, section: 1)]), res[0])
        XCTAssertEqual(.insertSections(IndexSet([2])), res[1])
        XCTAssertEqual(.insertRows([IndexPath(row: 0, section: 0)]), res[2])
        XCTAssertEqual(.updateRows([IndexPath(row: 1, section: 1)]), res[3])
        XCTAssertEqual(.updateRows([IndexPath(row: 0, section: 1)]), res[4])
        XCTAssertEqual([
            [DummySectionable(2, 0), DummySectionable(2, 1)],
            [DummySectionable(1, 0), DummySectionable(1, 1), DummySectionable(1, 2)],
            [DummySectionable(0, 1)]
            ], sections.map{ $0.objects })
    }
}
