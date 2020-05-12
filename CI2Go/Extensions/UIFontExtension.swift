//
//  UIFontExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIFont {
    convenience init(monotype size: CGFloat = 17) {
        self.init(name: "Source Code Pro", size: size)!
    }

    static var monotype: UIFont {
        let mtx = UIFontMetrics(forTextStyle: .body)
        return mtx.scaledFont(for: UIFont.init(monotype: UIFont.systemFontSize))
    }
}
