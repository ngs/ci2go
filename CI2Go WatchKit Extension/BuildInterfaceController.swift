//
//  BuildInterfaceController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/15/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit

class BuildInterfaceController: SingleBuildInterfaceController {

  @IBOutlet weak var timeLabel: WKInterfaceLabel!

  override func willActivate() {
    super.willActivate()
    let tracker = getDefaultGAITraker()
    tracker.set(kGAIScreenName, value: "Build Detail")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
  }

  override func updateViews() {
    super.updateViews()
    if let timeAgo = build?.startedAt?.timeAgoSimple() {
      timeLabel.setText(timeAgo + " ago")
    } else {
      timeLabel.setText("")
    }
  }

}
