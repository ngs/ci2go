//
//  APITokenCaptionView.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/19.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class APITokenCaptionView: UIView {
    let docURL = URL(string: "https://circleci.com/account/api")!
    @IBAction func openAPIDoc(_ sender: Any) {
        UIApplication.shared.open(docURL, options: [:]) { _ in }
    }
}
