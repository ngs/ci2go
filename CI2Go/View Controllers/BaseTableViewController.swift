//
//  BaseTableViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BaseTableViewController: UITableViewController {

  private var refreshTimer: NSTimer? = nil

  public func predicate() -> NSPredicate? {
    return nil
  }

  override public func awakeFromNib() {
    super.awakeFromNib()
    // FIXME: if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
    if 0 == NSDate().timeIntervalSinceNow {
      self.clearsSelectionOnViewWillAppear = false
      self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
    }
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.view.backgroundColor = ColorScheme().backgroundColor()
  }

  public func updatePredicate() {
//    self.fetchedResultsController.fetchRequest.predicate = predicate()
//    do {
//      try self.fetchedResultsController.performFetch()
//    } catch _ {
//    }
    self.tableView.reloadData()
  }

  override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//    return self.fetchedResultsController.sections?.count ?? 0
    return 0
  }

  override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if section < 0 { return 0 }
//    let sectionInfo = self.fetchedResultsController.sections![section]
//    return sectionInfo.numberOfObjects
    return 0
  }


  public func tableView(tableView: UITableView, cellIdentifierAtIndexPath indexPath: NSIndexPath) -> String {
    return "Cell"
  }

  override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cellIdentifier = self.tableView(tableView, cellIdentifierAtIndexPath: indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) 
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
  }

  // MARK: refresh timer

  public func scheduleNextRefresh() {
    invalidateRefreshTimer()
    let interval = CI2GoUserDefaults.standardUserDefaults().apiRefreshInterval
    if isViewLoaded() && view.window != nil && interval > 0 {
      refreshTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "refresh:", userInfo: nil, repeats: false)
    }
  }

  public func invalidateRefreshTimer() {
    refreshTimer?.invalidate()
    refreshTimer = nil
  }


  public func refresh(sender :AnyObject?) {
  }
}
