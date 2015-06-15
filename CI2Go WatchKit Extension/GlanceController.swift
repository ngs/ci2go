//
//  GlanceController.swift
//  CI2Go WatchKit Extension
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: SingleBuildInterfaceController {
  @IBOutlet weak var placeholderLabel: WKInterfaceLabel!
  override func willActivate() {
    super.willActivate()
    if CI2GoUserDefaults.standardUserDefaults().isLoggedIn {
      refresh()
      placeholderLabel.setHidden(true)
    } else {
      branchLabel.setHidden(true)
      buildNumLabel.setHidden(true)
      repoLabel.setHidden(true)
      statusGroup.setHidden(true)
      statusLabel.setHidden(true)
      commitMessageLabel.setHidden(true)
      authorLabel.setHidden(true)
      branchIcon.setHidden(true)
    }
  }

  func refresh() {
    self.initializeDB()
    CircleCIAPISessionManager().GET(CI2GoUserDefaults.standardUserDefaults().buildsAPIPath, parameters: ["limit": 1, "offset": 0],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
          if let ar = data as? NSArray {
            self.build = Build.MR_importFromObject(ar[0], inContext: context) as? Build
          }
          return
          }, completion: { (success: Bool, error: NSError!) -> Void in
            return
        })
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
    }
  }

}
