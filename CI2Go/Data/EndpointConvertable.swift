//
//  EndpointConvertable.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

protocol EndpointConvertable {
    var apiPath: String { get }
}

extension Equatable where Self: EndpointConvertable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.apiPath == rhs.apiPath
    }
}
