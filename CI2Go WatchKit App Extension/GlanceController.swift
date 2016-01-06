//
//  GlanceController.swift
//  CI2Go WatchKit Extension
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation
import RxSwift

class GlanceController: SingleBuildInterfaceController {
    @IBOutlet weak var placeholderLabel: WKInterfaceLabel!
    override func willActivate() {
        super.willActivate()
        //let tracker = getDefaultGAITraker()
        if CI2GoUserDefaults.standardUserDefaults().isLoggedIn {
            refresh()
            //tracker.set(kGAIScreenName, value: "Glance")
            placeholderLabel.setHidden(true)
        } else {
            //tracker.set(kGAIScreenName, value: "Glance Placehoker")
            branchLabel.setHidden(true)
            buildNumLabel.setHidden(true)
            repoLabel.setHidden(true)
            statusGroup.setHidden(true)
            statusLabel.setHidden(true)
            commitMessageLabel.setHidden(true)
            authorLabel.setHidden(true)
            branchIcon.setHidden(true)
        }
        //tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }

    func refresh() {
        Build.getRecent(0, limit: 1).subscribeNext { builds in
            self.build = builds.first
        }.addDisposableTo(disposeBag)
    }
    
}
