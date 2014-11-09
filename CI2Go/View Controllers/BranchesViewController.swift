//
//  BranchesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BranchesViewController: BaseTableViewController {
  public var project: Project?

  public override func createFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController {
    return Branch.MR_fetchAllSortedBy("name", ascending: false, withPredicate: predicate(), groupBy: nil, delegate: self, inContext: context)
  }

  public override func predicate() -> NSPredicate? {
    return NSPredicate(format: "project = %@", project!)
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 {
      cell.textLabel.text = "All branches"
    } else {
      let b = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as Branch
      cell.textLabel.text = b.name
    }
  }

  public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : (fetchedResultsController.sections![0] as NSFetchedResultsSectionInfo).numberOfObjects
  }

  public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let d = CI2GoUserDefaults.standardUserDefaults()
    if indexPath.section == 1 {
      d.selectedBranch = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Branch
    } else {
      d.selectedBranch = nil
    }
    d.selectedProject = project
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
