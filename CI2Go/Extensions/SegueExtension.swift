//
//  SegueExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/20.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

enum SegueIdentifier: String {
    case showSettings = "showSettings"
    case showThemeList = "showThemeList"
    case showBuildDetail = "showBuildDetail"
    case showBuildLog = "showBuildLog"
    case showBranches = "showBranches"
    case unwindSegue = "unwindSegue"
    case showBuildConfig = "showBuildConfig"
    case showQuickLook = "showQuickLook"
    case login = "login"
}

extension UIViewController {
    func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
}
