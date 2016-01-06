//
//  UIViewExtensionSpec.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/6/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import UIKit
import Quick
import Nimble

@testable import CI2Go

class UIViewExtensionSpec: QuickSpec {
    override func spec() {
        describe("UIView#subviewsForClass(:)") {
            it("finds subviews") {
                let v = NSBundle(forClass: self.dynamicType).loadNibNamed("SubviewsForClassSampleView", owner: self, options: [:]).first as! UIView
                let subviews = v.subviewsForClass(UILabel.self)
                let texts = subviews.map{ ($0 as! UILabel).text! }
                expect(texts).to(equal(["B", "C", "A"]))
            }
        }
    }
}