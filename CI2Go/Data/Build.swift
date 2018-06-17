//
//  Build.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Build: Decodable {
    typealias BuildParameters = [String: String]
    
    let number: Int
    let compareURL: URL?
    let buildParameters: BuildParameters
    let isOSS: Bool
    let steps: [BuildStep]
    
    enum CodingKeys: String, CodingKey {
        case number = "build_num"
        case compareURL = "compare"
        case buildParameters = "build_parameters"
        case isOSS = "oss"
        case steps = "steps"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        number = try values.decode(Int.self, forKey: .number)
        let compareURLStr = (try values.decode(String.self, forKey: .compareURL))
            .replacingOccurrences(of: "^", with: "")
        compareURL = URL(string: compareURLStr)
        buildParameters = (try? values.decode(BuildParameters.self, forKey: .compareURL)) ??
            BuildParameters()
        isOSS = (try? values.decode(Bool.self, forKey: .isOSS)) ?? false
        steps = (try? values.decode([BuildStep].self, forKey: .steps)) ?? []
    }
}

