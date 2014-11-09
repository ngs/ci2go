//
//  BuildsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BuildsViewController: BaseTableViewController {

  public var offset = 0, isLoading = false
  
  public override func viewDidAppear(animated: Bool) {
    let d = CI2GoUserDefaults.standardUserDefaults()
    if !(d.circleCIAPIToken?.length > 0) {
      performSegueWithIdentifier("showSettings", sender: nil)
    } else {
      load(false)
    }
  }

  public override func viewWillAppear(animated: Bool) {
    self.updatePredicate()
    super.viewWillAppear(animated)
  }

  public override func createFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController {
    return Build.fetchAllSortedBy("queuedAt", ascending: true, withPredicate: predicate(), groupBy: nil, delegate: self, inContext: context)
  }

  public override func predicate() -> NSPredicate? {
    let d = CI2GoUserDefaults.standardUserDefaults()
    if let branch = d.selectedBranch {
      return NSPredicate(format: "branch = %@", branch)
    }
    if let project = d.selectedProject {
      return NSPredicate(format: "project = %@", project)
    }
    return super.predicate()
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let buildCell = cell as BuildTableViewCell
    let build = fetchedResultsController.objectAtIndexPath(indexPath) as? Build
    buildCell.build = build
  }

  public func load(more: Bool) {
    if isLoading { return }
    if more {
      offset += 50
    } else {
      offset = 0
    }
    isLoading = true
    CircleCIAPISessionManager().GET(CI2GoUserDefaults.standardUserDefaults().buildsAPIPath, parameters: ["limit": 100, "offset": offset],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        MagicalRecord.saveWithBlockAndWait({ (context: NSManagedObjectContext!) -> Void in
          if let ar = data as? NSArray {
            Build.MR_importFromArray(ar, inContext: context)
          }
          self.isLoading = false
        })
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
        self.isLoading = false
    }
  }

  public override func scrollViewDidScroll(scrollView: UIScrollView) {
    let contentHeight = scrollView.contentSize.height
    let height = scrollView.frame.size.height
    let top = scrollView.frame.origin.y
    let scrollTop = scrollView.contentOffset.y
    let diff = contentHeight - scrollTop - top
    if diff < height && self.fetchedResultsController.sections?.count > 0 {
      load(true)
    }
  }

}
