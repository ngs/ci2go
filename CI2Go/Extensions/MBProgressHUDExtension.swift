//
//  MBProgressHUDExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/20.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import MBProgressHUD

extension MBProgressHUD {
    enum Icon: String {
        case warning = "hud-warning"
        case success = "hud-success"
        var image: UIImage {
            return UIImage(named: rawValue)!
        }
    }
    var icon: Icon? {
        get {
            fatalError("No getter")
        }
        set(icon) {
            customView = UIImageView(image: icon?.image)
        }
    }
}
