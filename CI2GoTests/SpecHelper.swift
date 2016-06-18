//
//  SpecHelper.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import OHHTTPStubs
import RealmSwift
import RxSwift
import Nimble
import RxBlocking

func fixtureJSON(fileName: String, _ inBundleForClass: AnyClass) -> AnyObject {
    let file = OHPathForFile(fileName, inBundleForClass)!
    let data = NSData(contentsOfFile: file)!
    return try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
}

extension ObservableType {
    func futureValue() -> E? {
        var value: E? = nil
        do {
          value = try self.toBlocking().first()
        } catch _ {}
        return value
    }
}