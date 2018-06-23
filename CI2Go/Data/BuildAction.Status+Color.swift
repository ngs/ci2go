//
//  BuildAction.Status+Color.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension BuildAction.Status {
    var color: UIColor {
        return ColorScheme.current.action(status: self)
    }
}
