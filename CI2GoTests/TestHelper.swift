//
//  TestHelper.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

private class BundleClass {}

extension Bundle {
    static var test: Bundle {
        return Bundle(for: BundleClass.self)
    }
}

extension Data {
    init(json: String) throws {
        let file = Bundle.test.url(forResource: json, withExtension: "json")!
        try self.init(contentsOf: file)
    }
}
