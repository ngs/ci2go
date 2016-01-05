//
//  BuildLogTextView.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BuildLogTextView: UITextView {


    public var logText: String? = nil {
        didSet {
            let s = ColorScheme()
            if logText != nil {
                attributedText = s.ansiHelper.attributedStringWithANSIEscapedString(logText!)
            } else {
                attributedText = nil
            }
            self.scrollToBottom()
        }
    }

    public func scrollToBottom() {
        if contentSize.height > bounds.height {
            scrollRangeToVisible(NSMakeRange(attributedText.length - 1, 1))
        }
    }
    
}
