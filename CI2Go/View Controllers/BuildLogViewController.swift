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
import Crashlytics

class BuildLogViewController: UIViewController, UITextViewDelegate {
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
    var logSubscription: Disposable?, pusherSubscription: Disposable?

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard let buildAction = buildAction else { return }
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Build Log Screen")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        Answers.logContentViewWithName("Build Log", contentType: "Build Action", contentId: buildAction.id, customAttributes: nil)
        logSubscription = buildAction.log.subscribeNext { log in
            self.textView.attributedText = log
            self.textView.scrollIfNeeded()
            self.view.setNeedsLayout()
        }
        if buildAction.status == .Running {
            pusherSubscription = AppDelegate.current.pusherClient.subscribeBuildLog(buildAction).subscribe()
        }
    }

    var touching = false

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        logSubscription?.dispose()
        logSubscription = nil
        pusherSubscription?.dispose()
        pusherSubscription = nil
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        touching = true
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard textView.shouldScrollToBottom() && touching else { return }
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        let top = scrollView.frame.origin.y
        let scrollTop = scrollView.contentOffset.y
        let diff = contentHeight - scrollTop - top
        textView.snapBottom = diff < height + 50
        touching = false
    }
}
