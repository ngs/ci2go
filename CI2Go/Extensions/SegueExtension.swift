//
//  SegueExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/20.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

enum SegueIdentifier: String {
    case showSettings
    case showThemeList
    case showBuildDetail
    case showBuildLog
    case showBranches
    case unwindSegue
    case showBuildConfig
    case showQuickLook
    case login
}

extension UIViewController {
    func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
}
