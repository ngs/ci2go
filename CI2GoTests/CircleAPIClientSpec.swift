//
//  CircleAPIClientSpec.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/3/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble
import OHHTTPStubs
import Alamofire

@testable import CI2Go

class CircleAPIClientSpec: QuickSpec {
    override func spec() {
        describe("CircleAPIClient#apiURLForPath") {
            it("returns URL from path") {
                expect(CircleAPIClient(token: "test").apiURLForPath("foo")).to(equal(NSURL(string: "https://circleci.com/api/v1/foo?circle-token=test")!))
            }
        }
    }
}
