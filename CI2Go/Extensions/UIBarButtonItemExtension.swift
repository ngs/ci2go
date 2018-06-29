//
//  UIBarButtonItemExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/29.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    convenience init(activityIndicatorStyle: UIActivityIndicatorViewStyle) {
        let av = UIActivityIndicatorView(activityIndicatorStyle: activityIndicatorStyle)
        av.startAnimating()
        self.init(customView: av)
    }
}
