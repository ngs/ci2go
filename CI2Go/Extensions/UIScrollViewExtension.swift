//
//  UIScrollViewExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIScrollView {
    var contentHeight: CGFloat {
        return contentSize.height
    }

    var offsetY: CGFloat {
        return contentOffset.y + safeAreaInsets.top
    }

    var height: CGFloat {
        return frame.height
    }

    var isOverflowed: Bool {
        return contentHeight > height
    }

    var bottomOffsetY: CGFloat {
        return contentHeight - contentOffset.y - height + safeAreaInsets.bottom
    }

    var bottomOffset: CGPoint {
        let x = contentOffset.x
        let y = contentHeight - height + safeAreaInsets.bottom
        return CGPoint(x: x, y: y)
    }

    func scrollToBottom(animated: Bool = false) {
        if isOverflowed {
            if let textView = self as? UITextView {
                let location = textView.attributedText.length
                let bottom = NSRange(location: location, length: 0)
                textView.scrollRangeToVisible(bottom)
                return
            }
            setContentOffset(bottomOffset, animated: animated)
        }
    }
}
