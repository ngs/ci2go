//
//  BuildLogTextView.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BuildLogTextView: UITextView {

    public var snapBottom = true

    public func scrollIfNeeded() {
        if snapBottom {
            scrollToBottom()
        }
    }

    public func shouldScrollToBottom() -> Bool {
        layoutIfNeeded()
        let h = layoutManager.usedRectForTextContainer(textContainer).height
        return h > frame.size.height
    }

    public func scrollToBottom() {
        if shouldScrollToBottom() {
            UIView.setAnimationsEnabled(false)
            scrollRangeToVisible(NSMakeRange(attributedText.length - 1, 0))
            UIView.setAnimationsEnabled(true)
            scrollEnabled = false
            scrollEnabled = true
        }
    }
}
