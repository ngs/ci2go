//
//  SingleBuildInterfaceController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit

class SingleBuildInterfaceController: WKInterfaceController {

  @IBOutlet weak var branchLabel: WKInterfaceLabel!
  @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
  @IBOutlet weak var repoLabel: WKInterfaceLabel!
  @IBOutlet weak var statusGroup: WKInterfaceGroup!
  @IBOutlet weak var statusLabel: WKInterfaceLabel!
  @IBOutlet weak var commitMessageLabel: WKInterfaceLabel!
  @IBOutlet weak var authorLabel: WKInterfaceLabel!
  private var _build: Build?

  override func awakeFromNib() {
    super.awakeFromNib()
    self.build = nil
  }

  internal var build: Build? {
    get { return _build }
    set(value) {
      if value != _build {
        _build = value
        let cs = ColorScheme()
        if value?.status != nil {
          let status = value!.status!
          self.statusGroup.setBackgroundColor(cs.badgeColor(status: status))
          self.statusLabel.setText(status.humanize)
          self.repoLabel.setText(value!.project?.path)
          let numText = "#\(value!.number.intValue)"
          self.buildNumLabel.setText(numText)
          self.setTitle(numText)
          self.branchLabel.setText(value!.branch?.name)
          self.commitMessageLabel.setText(value!.triggeredCommit?.subject)
          self.authorLabel.setText(value!.user?.name)
        } else {
          self.statusGroup.setBackgroundColor(cs.badgeColor(status: ""))
          self.statusLabel.setText("")
          self.repoLabel.setText("")
          self.buildNumLabel.setText("")
          self.branchLabel.setText("")
          self.commitMessageLabel.setText("")
          self.authorLabel.setText("")
        }
      }
    }
  }

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    self.initializeDB()
    if let buildID = context as? String {
      self.build = Build.MR_findFirstByAttribute("buildID", withValue: buildID)
    }
  }

  @IBAction func handleRefreshMenuItem() {
    CircleCIAPISessionManager().POST(self.build?.apiPath!.stringByAppendingPathComponent("retry"), parameters: [],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        self.popController()
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
    }
  }
}