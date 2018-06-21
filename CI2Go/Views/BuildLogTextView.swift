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
            let location = attributedText.length
            let bottom = NSMakeRange(location, 0)
            scrollRangeToVisible(bottom)
        }
    }

}
