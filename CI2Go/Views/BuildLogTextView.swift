//
//  BuildLogTextView.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class BuildLogTextView: UITextView {

    var snapToBottom = true

    func scrollIfNeeded() {
        if snapToBottom {
            scrollToBottom()
        }
    }

    func shouldScrollToBottom() -> Bool {
        layoutIfNeeded()
        let h = layoutManager.usedRect(for: textContainer).height
        return h > frame.size.height
    }

    func scrollToBottom() {
        if shouldScrollToBottom() {
            UIView.setAnimationsEnabled(false)
            let location = attributedText.length - 1
            let bottom = NSMakeRange(location, 1)
            scrollRangeToVisible(bottom)
            UIView.setAnimationsEnabled(true)
            isScrollEnabled = false
            isScrollEnabled = true
        }
    }

}
