//
//  ProjectsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class ProjectsViewController: BaseTableViewController {

  @IBAction func cancelButtonTapped(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  override public func createFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController {
    return Project.MR_fetchAllSortedBy("projectID", ascending: false, withPredicate: predicate(), groupBy: nil, delegate: self)
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 {
      cell.textLabel.text = "All projects"
    } else {
      let project = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as Project
      cell.textLabel.text = project.repositoryName
      cell.detailTextLabel?.text = project.username
      cell.detailTextLabel?.alpha = 0.5
    }
  }

  public override func tableView(tableView: UITableView, cellIdentifierAtIndexPath indexPath: NSIndexPath) -> String {
    return "Cell\(indexPath.section)"
  }

  public override func viewDidAppear(animated: Bool) {
    CircleCIAPISessionManager().GET("projects", parameters: nil,
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        MagicalRecord.saveWithBlockAndWait({ (context: NSManagedObjectContext!) -> Void in
          if let ar = data as? NSArray {
            Project.MR_importFromArray(ar, inContext: context)
          }
        })
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
    }
  }

  public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : (fetchedResultsController.sections![0] as NSFetchedResultsSectionInfo).numberOfObjects
  }

  public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let vc = segue.destinationViewController as? BranchesViewController
    let cell = sender as? UITableViewCell
    if vc != nil && cell != nil {
      if let indexPath = tableView.indexPathForCell(cell!) {
        vc?.project = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Project
      }
    }
  }

  public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 {
      let d = CI2GoUserDefaults.standardUserDefaults()
      d.selectedProject = nil
      d.selectedBranch = nil
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
}
