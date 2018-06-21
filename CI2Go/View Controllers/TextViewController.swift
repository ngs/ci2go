//
//  TextViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!

    var text: String? = nil {
        didSet {
            textView?.isScrollEnabled = false
            textView?.text = text
            textView?.isScrollEnabled = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let s = ColorScheme.current
        textView.backgroundColor = s.background
        textView.textColor = s.foreground
        textView.isScrollEnabled = false
        textView.text = text
        textView.isScrollEnabled = true
    }
}
