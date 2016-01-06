//
//  UIViewExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/6/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIView {
    func subviewsForClass(klass: AnyClass) -> [UIView] {
        var ret = [UIView]()
        self.subviews.forEach { v in
            if v.dynamicType == klass {
                ret.append(v)
            }
            ret.appendContentsOf(v.subviewsForClass(klass))
        }
        return ret
    }
}