//
//  UIAlertControllerExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIAlertController {
    func customize() {
        customize(in: view)
    }
    fileprivate func customize(in view: UIView) {
        let scheme = ColorScheme.current
        if view.backgroundColor != nil {
            view.backgroundColor = scheme.background
        }
        if let label = view as? UILabel {
            label.textColor = scheme.bold
        }
        if let button = view as? UIButton {
            button.setTitleColor(scheme.bold, for: .normal)
        }
        view.tintColor = scheme.bold
        print(view, view.backgroundColor, view.tintColor)
        view.subviews.forEach { v in
            self.customize(in: v)
        }
    }
}
