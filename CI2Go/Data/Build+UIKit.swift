//
//  Build+UIKit.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension Build {
    var isSSHAvailable: Bool {
        if let first = sshURLs.first, status == .running {
            return UIApplication.shared.canOpenURL(first)
        }
        return false
    }
}
