//
//  SingleBuildInterfaceController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import AFNetworking

class SingleBuildInterfaceController: WKInterfaceController {

  @IBOutlet weak var branchLabel: WKInterfaceLabel!
  @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
  @IBOutlet weak var repoLabel: WKInterfaceLabel!
  @IBOutlet weak var statusGroup: WKInterfaceGroup!
  @IBOutlet weak var statusLabel: WKInterfaceLabel!
  @IBOutlet weak var commitMessageLabel: WKInterfaceLabel!
  @IBOutlet weak var authorLabel: WKInterfaceLabel!
  @IBOutlet weak var branchIcon: WKInterfaceImage!
  private var _build: Build?

  override func awakeFromNib() {
    super.awakeFromNib()
    self.build = nil
  }

  internal var build: Build? {
    get {
      return _build
    }
    set(value) {
      if value != _build {
        _build = value
        updateViews()
      }
    }
  }

  func updateViews() {
    let cs = ColorScheme()
    if build == nil {
      self.statusGroup.setBackgroundColor(cs.badgeColor(status: ""))
      self.statusLabel.setText("")
      self.repoLabel.setText("")
      self.buildNumLabel.setText("")
      self.branchLabel.setText("")
      self.commitMessageLabel.setText("")
      self.authorLabel.setText("")
    } else {
      let status = build!.status!
      self.statusGroup.setBackgroundColor(cs.badgeColor(status: status))
      self.statusLabel.setText(status.humanize)
      self.repoLabel.setText(build!.project?.path)
      let numText = "#\(build!.number.intValue)"
      self.buildNumLabel.setText(numText)
      self.setTitle(numText)
      self.branchLabel.setText(build!.branch?.name)
      self.commitMessageLabel.setText(build!.triggeredCommit?.subject)
      self.authorLabel.setText(build!.user?.name)
    }
  }

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    self.initializeDB()
    let tracker = getDefaultGAITraker()
    if let buildID = context as? String {
      self.build = Build.MR_findFirstByAttribute("buildID", withValue: buildID)
    } else {
      self.build = Build.MR_findFirstWithPredicate(CI2GoUserDefaults.standardUserDefaults().buildsPredicate, sortedBy: "queuedAt", ascending: false)
    }
    let dict = GAIDictionaryBuilder.createEventWithCategory("build", action: "set", label: self.build?.apiPath, value: 1).build() as [NSObject : AnyObject]
    tracker.send(dict)
  }

  @IBAction func handleRefreshMenuItem() {
    guard let apiPath = self.build?.apiPath else { return }
    CircleCIAPISessionManager().POST("\(apiPath)/retry",
      parameters: [:],
      success: { (op, data) in
        self.popController()
      })
      { (op, err) in
    }
  }
}