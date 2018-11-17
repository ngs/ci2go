//
//  MainSplitViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/11/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class MainSplitViewController: UISplitViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ColorScheme.current.statusBarStyle
    }

}
