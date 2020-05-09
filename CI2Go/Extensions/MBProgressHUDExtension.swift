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
        // swiftlint:disable:next implicit_getter
        get {
            switch customView?.tag {
            case 1:
                return .warning
            case 2:
                return .warning
            default:
                return .none
            }
        }

        set(icon) {
            customView = UIImageView(image: icon?.image)
            switch icon {
            case .warning:
                self.customView?.tag = 1
            case .success:
                self.customView?.tag = 2
            case .none:
                self.customView?.tag = 0
            }
        }
    }
}
