//
//  TextViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 3/10/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    @IBOutlet var textView: UITextView?

    var text: String? {
        didSet {
            textView?.text = text
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textView?.font = UIFont.sourceCodeProRegular(12)
        let s = ColorScheme()
        textView?.textColor = s.foregroundColor()
        textView?.backgroundColor = s.backgroundColor()
        textView?.text = text
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView?.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }

}
