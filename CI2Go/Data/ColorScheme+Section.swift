//
//  ColorScheme+Section.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/19.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension ColorScheme: Sectionable {
    typealias Element = String

    var sectionTitle: String? {
        return String(name.first!).uppercased()
    }

    var sectionComparable: String {
        return sectionTitle!
    }

    static func < (lhs: ColorScheme, rhs: ColorScheme) -> Bool {
        return lhs.name.uppercased() < rhs.name.uppercased()
    }

    static func == (lhs: ColorScheme, rhs: ColorScheme) -> Bool {
        return lhs.name.uppercased() == rhs.name.uppercased()
    }
}
