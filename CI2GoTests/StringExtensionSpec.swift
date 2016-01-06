//
//  StringExtensionSpec.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/3/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import CI2Go

class StringExtensionSpec: QuickSpec {
    override func spec() {
        describe("String#firstString") {
            it("returns first string") {
                expect("foo".firstString as String).to(equal("f"))
                expect("".firstString as String).to(equal(""))
                expect("Foo".firstString as String).to(equal("F"))
            }
        }
        describe("humanize") {
            it("returns humanized string") {
                expect("it_works".humanize as String).to(equal("It Works"))
            }
        }
    }
}