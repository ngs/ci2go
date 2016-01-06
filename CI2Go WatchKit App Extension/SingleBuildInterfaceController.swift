//
//  SingleBuildInterfaceController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import RealmSwift
import RxSwift

class SingleBuildInterfaceController: WKInterfaceController {

    lazy var realm: Realm = {
        return try! Realm()
    }()

    let disposeBag = DisposeBag()

    @IBOutlet weak var branchLabel: WKInterfaceLabel!
    @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
    @IBOutlet weak var repoLabel: WKInterfaceLabel!
    @IBOutlet weak var statusGroup: WKInterfaceGroup!
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var commitMessageLabel: WKInterfaceLabel!
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    @IBOutlet weak var branchIcon: WKInterfaceImage!

    var build: Build? {
        didSet { updateViews() }
    }

    func updateViews() {
        let cs = ColorScheme()
        if let build = build, status = build.status {
            self.statusGroup.setBackgroundColor(cs.badgeColor(status: status))
            self.statusLabel.setText(status.humanize)
            self.repoLabel.setText(build.project?.path)
            let numText = "#\(build.number)"
            self.buildNumLabel.setText(numText)
            self.setTitle(numText)
            self.branchLabel.setText(build.branch?.name)
            self.commitMessageLabel.setText(build.triggeredCommit?.subject)
            self.authorLabel.setText(build.user?.name)
        } else {
            self.statusGroup.setBackgroundColor(cs.badgeColor(status: nil))
            self.statusLabel.setText("")
            self.repoLabel.setText("")
            self.buildNumLabel.setText("")
            self.branchLabel.setText("")
            self.commitMessageLabel.setText("")
            self.authorLabel.setText("")
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // let tracker = getDefaultGAITraker()
        if let buildID = context as? String {
            self.build = realm.objectForPrimaryKey(Build.self, key: buildID)
        } else {
            self.build = realm.objects(Build.self)
                .filter(CI2GoUserDefaults.standardUserDefaults().buildsPredicate)
                .sorted("queuedAt").first
        }
        //let dict = GAIDictionaryBuilder.createEventWithCategory("build", action: "set", label: self.build?.apiPath, value: 1).build() as [NSObject : AnyObject]
        //tracker.send(dict)
    }

    @IBAction func handleRefreshMenuItem() {
        self.build?.post("retry").subscribeNext { build in
            self.pushControllerWithName("Build Detail", context: build.id)
        }.addDisposableTo(disposeBag)
    }
}