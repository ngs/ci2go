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
}
