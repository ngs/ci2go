//
//  AppDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/14.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        activateWCSession()
        return true
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .format)
    }
}
