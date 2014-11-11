//
//  BaseTableViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BaseTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

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

  public func updatePredicate() {
    self.fetchedResultsController.fetchRequest.predicate = predicate()
    self.fetchedResultsController.performFetch(nil)
    self.tableView.reloadData()
  }

  override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.fetchedResultsController.sections?.count ?? 0
  }

  override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section < 0 { return 0 }
    let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    return sectionInfo.numberOfObjects
  }


  public func tableView(tableView: UITableView, cellIdentifierAtIndexPath indexPath: NSIndexPath) -> String {
    return "Cell"
  }

  override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cellIdentifier = self.tableView(tableView, cellIdentifierAtIndexPath: indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
  }

  // MARK: - Fetched results controller

  public func createFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController {
    return NSFetchedResultsController()
  }

  var fetchedResultsController: NSFetchedResultsController {
    if (_fetchedResultsController == nil) {
      var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
      appDelegate.initializeDB()
      _fetchedResultsController = self.createFetchedResultsController(NSManagedObjectContext.MR_defaultContext())
    }
    return _fetchedResultsController!
  }
  var _fetchedResultsController: NSFetchedResultsController? = nil

  public func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
  }

  public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
      self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .None)
    case .Delete:
      self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .None)
    default:
      return
    }
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .None)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    case .Update:
      let cell = tableView.cellForRowAtIndexPath(newIndexPath)
      if cell != nil {
        self.configureCell(cell!, atIndexPath: newIndexPath)
      }
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
      tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .None)
    default:
      return
    }
  }

  public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
  }

  public func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
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
