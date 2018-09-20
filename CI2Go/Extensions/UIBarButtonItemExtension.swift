//
//  UIBarButtonItemExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/29.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    convenience init(activityIndicatorStyle: UIActivityIndicatorView.Style) {
        let indicatorView = UIActivityIndicatorView(style: activityIndicatorStyle)
        indicatorView.startAnimating()
        self.init(customView: indicatorView)
    }
}
