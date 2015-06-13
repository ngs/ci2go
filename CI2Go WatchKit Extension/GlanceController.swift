//
//  GlanceController.swift
//  CI2Go WatchKit Extension
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

  @IBOutlet weak var branchLabel: WKInterfaceLabel!
  @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
  @IBOutlet weak var repoLabel: WKInterfaceLabel!
  @IBOutlet weak var statusGroup: WKInterfaceGroup!
  @IBOutlet weak var statusLabel: WKInterfaceLabel!

  override func awakeFromNib() {
    let cs = ColorScheme()
    let color = cs.badgeColor(status: "")
    self.statusGroup.setBackgroundColor(color)
    self.statusLabel.setText("")
    self.repoLabel.setText("")
    self.buildNumLabel.setText("")
    self.branchLabel.setText("")
    super.awakeFromNib()
  }

  override func willActivate() {
    super.willActivate()
    refresh()
  }

  func refresh() {
    self.initializeDB()
    CircleCIAPISessionManager().GET(CI2GoUserDefaults.standardUserDefaults().buildsAPIPath, parameters: ["limit": 1, "offset": 0],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
          if let ar = data as? NSArray {
            let build = Build.MR_importFromObject(ar[0], inContext: context) as! Build
            let cs = ColorScheme()
            if build.status == nil { return }
            let status = build.status!
            let color = cs.badgeColor(status: status)
            self.statusGroup.setBackgroundColor(color)
            self.statusLabel.setText(status.humanize)
            self.repoLabel.setText(build.project?.path)
            self.buildNumLabel.setText("#\(build.number.intValue)")
            self.branchLabel.setText(build.branch?.name)
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
