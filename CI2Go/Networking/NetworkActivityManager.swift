//
//  NetworkActivityManager.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/20.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct NetworkActivityManager {
    fileprivate static var count = 0

    static func start() {
        count += 1
        updateVisibility()
    }

    static func stop() {
        guard count > 0 else { return }
        count -= 1
        updateVisibility()
    }

    private static func updateVisibility() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = count > 0
        }
    }

}
