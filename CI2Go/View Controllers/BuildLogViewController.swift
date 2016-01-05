//
//  BuildLogViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD

class BuildLogViewController: UIViewController {
    @IBOutlet weak var textView: BuildLogTextView!
    let disposeBag = DisposeBag()
    var buildAction: BuildAction? = nil {
        didSet {
            title = buildAction?.name
            let tracker = GAI.sharedInstance().defaultTracker
            let dict = GAIDictionaryBuilder.createEventWithCategory("build-log", action: "set", label: buildAction?.actionType, value: 1).build() as [NSObject : AnyObject]
            tracker.send(dict)
        }
    }
    var logSubscription: Disposable?
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Build Log Screen")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        logSubscription = logSubscription ?? buildAction?.log.subscribeNext { log in
            self.textView.logText = log
            self.view.setNeedsLayout()
        }
    }
}
