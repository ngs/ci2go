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
            return .systemGreen
        case .running:
            return .systemBlue
        case .failed, .timedout, .infrastructureFail, .noTests:
            return .systemRed
        default:
            return .systemGray
        }
    }
}
