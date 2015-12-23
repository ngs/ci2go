//
//  BuildsInterfaceController.swift
//  CI2Go WatchKit Extension
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation
import AFNetworking
import MagicalRecord

class BuildsInterfaceController: WKInterfaceController {
  @IBOutlet weak var interfaceTable: WKInterfaceTable!
  @IBOutlet weak var placeholderGroup: WKInterfaceGroup!

  let MAX_BUILDS = Int(20)
  var builds: [Build]?

  override func willActivate() {
    super.willActivate()
    let tracker = getDefaultGAITraker()
    if CI2GoUserDefaults.standardUserDefaults().isLoggedIn {
      self.refresh()
      placeholderGroup.setHidden(true)
      tracker.set(kGAIScreenName, value: "Builds")
    } else {
      interfaceTable.setHidden(true)
      tracker.set(kGAIScreenName, value: "Builds Placeholer")
    }
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
  }

  override func didDeactivate() {
    super.didDeactivate()
  }

  func refresh() {
    self.initializeDB()
    self.updateList()
    CircleCIAPISessionManager().GET(CI2GoUserDefaults.standardUserDefaults().buildsAPIPath, parameters: ["limit": MAX_BUILDS, "offset": 0],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
          if let ar = data as? NSArray {
            Build.MR_importFromArray(ar as [AnyObject], inContext: context)
          }
          }, completion: { (success: Bool, error: NSError!) -> Void in
            self.updateList()
        })
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
    }
  }

  func updateList() {
    let cnt = Int(Build.MR_countOfEntitiesWithPredicate(CI2GoUserDefaults.standardUserDefaults().buildsPredicate))
    if(cnt > self.MAX_BUILDS) {
      self.interfaceTable.setNumberOfRows(self.MAX_BUILDS, withRowType: "default")
    } else {
      self.interfaceTable.setNumberOfRows(cnt, withRowType: "default")
    }
    let fr = NSFetchRequest(entityName: "Build")
    fr.fetchLimit = self.MAX_BUILDS
    fr.predicate = CI2GoUserDefaults.standardUserDefaults().buildsPredicate
    fr.sortDescriptors = [NSSortDescriptor(key: "queuedAt", ascending: false)]
    let res = Build.MR_executeFetchRequest(fr) as! [Build]
    for var i = 0; i < res.count; i++ {
      let row = self.interfaceTable.rowControllerAtIndex(i) as! BuildTableRowController
      row.build = res[i]
    }
    self.builds = res
  }

  override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
    let row = table.rowControllerAtIndex(rowIndex) as! BuildTableRowController
    let build = row.build
    _ = try? build!.managedObjectContext?.existingObjectWithID(build!.objectID)
    return build!.buildID
  }

}
