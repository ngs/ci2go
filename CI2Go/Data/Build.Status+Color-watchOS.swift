//
//  Build.Status+Color.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension Build.Status {
    var color: UIColor {
        switch self {
        case .success, .fixed:
            return .green
        case .running:
            return .blue
        case .failed, .timedout, .infrastructureFail, .noTests:
            return .red
        default:
            return .gray
        }
    }
}
