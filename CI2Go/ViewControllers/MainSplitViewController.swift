//
//  MainSplitViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/11/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class MainSplitViewController: UISplitViewController {
    static var current: MainSplitViewController? {
        return UIApplication.shared.windows.first?.rootViewController as? MainSplitViewController
    }

    var firstNavigationController: UINavigationController? {
        return viewControllers.first as? UINavigationController
    }

    var buildsViewController: BuildsViewController? {
        return viewControllers
            .filter { $0 is UINavigationController }
            .map {
                (($0 as? UINavigationController)?.viewControllers ?? [])
                    .filter { $0 is BuildsViewController }
                    .map { $0 as! BuildsViewController } // swiftlint:disable:this force_cast
            }
            .flatMap { $0 }
            .first
    }

    var buildsLogsViewController: BuildLogViewController? {
        return viewControllers
            .filter { $0 is UINavigationController }
            .map {
                (($0 as? UINavigationController)?.viewControllers ?? [])
                    .filter { $0 is BuildLogViewController }
                    .map { $0 as! BuildLogViewController } // swiftlint:disable:this force_cast
            }
            .flatMap { $0 }
            .first
    }

}
