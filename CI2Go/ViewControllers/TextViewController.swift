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
        textView.isScrollEnabled = false
        textView.text = text
        textView.isScrollEnabled = true
        textView.font = .monotype
    }
}
