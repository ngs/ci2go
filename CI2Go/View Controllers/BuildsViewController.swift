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

  public override func awakeFromNib() {
    super.awakeFromNib()
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl!)
  }

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
    NSNotificationCenter().addObserverForName(kCI2GoBranchChangedNotification, object: self, queue: nil) { (n: NSNotification!) -> Void in
      dispatch_async(dispatch_get_main_queue(), {
        self.updatePredicate()
        self.load(false)
      })
    }
  }

  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    NSNotificationCenter().removeObserver(self)
  }

  public override func createFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController {
    return Build.fetchAllSortedBy("queuedAt", ascending: false, withPredicate: predicate(), groupBy: nil, delegate: self, inContext: context)
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
    if isLoading {
      refreshControl?.endRefreshing()
      return
    }
    if more {
      offset += 50
    } else {
      offset = 0
    }
    isLoading = true
    CircleCIAPISessionManager().GET(CI2GoUserDefaults.standardUserDefaults().buildsAPIPath, parameters: ["limit": 100, "offset": offset],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        self.refreshControl?.endRefreshing()
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
          if let ar = data as? NSArray {
            Build.MR_importFromArray(ar, inContext: context)
          }
          return
          }, completion: { (success: Bool, error: NSError!) -> Void in
            self.isLoading = false
            return
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

  public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let vc = segue.destinationViewController as? BuildStepsViewController
    let cell = sender as? BuildTableViewCell
    var build = sender as? Build
    if build == nil { build = cell?.build }
    vc?.build = build
  }

  public func refresh(sender :AnyObject?) {
    load(false)
  }
  
}
