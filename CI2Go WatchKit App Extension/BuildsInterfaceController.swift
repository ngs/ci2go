//
//  BuildsInterfaceController.swift
//  CI2Go WatchKit Extension
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation
import RealmSwift
import RxSwift

class BuildsInterfaceController: WKInterfaceController {
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    @IBOutlet weak var placeholderGroup: WKInterfaceGroup!

    let disposeBag = DisposeBag()
    let maxBuilds = 20

    override func willActivate() {
        super.willActivate()
        setupRealm()
        self.updateList()
        self.placeholderGroup.setHidden(true)
        self.interfaceTable.setHidden(false)
        NSNotificationCenter.defaultCenter().rx_notification("hoge").subscribeNext { _ in
            //let tracker = getDefaultGAITraker()
            if CI2GoUserDefaults.standardUserDefaults().isLoggedIn {
                self.refresh()
                self.placeholderGroup.setHidden(true)
                //tracker.set(kGAIScreenName, value: "Builds")
            } else {
                self.interfaceTable.setHidden(true)
                //tracker.set(kGAIScreenName, value: "Builds Placeholer")
            }
            //tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        }.addDisposableTo(disposeBag)
    }

    func refresh() {
        Build.getRecent(0, limit: maxBuilds).subscribeNext { builds in
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(builds, update: true)
                }
                self.updateList()
            }
        }.addDisposableTo(disposeBag)
    }

    func updateList() {
        let realm = try! Realm()
        let builds = realm.objects(Build)
        let cnt = builds.count
        if(cnt > maxBuilds) {
            self.interfaceTable.setNumberOfRows(maxBuilds, withRowType: "default")
        } else {
            self.interfaceTable.setNumberOfRows(cnt, withRowType: "default")
        }
        for var i = 0; i < cnt && i < maxBuilds; i++ {
            if let row = self.interfaceTable.rowControllerAtIndex(i) as? BuildTableRowController {
                row.build = builds[i]
            }
        }
    }

    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if let row = table.rowControllerAtIndex(rowIndex) as? BuildTableRowController
            , build = row.build {
                return build.id
        }
        return nil
    }
    
}
