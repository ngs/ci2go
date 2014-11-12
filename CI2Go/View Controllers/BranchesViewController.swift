//
//  BranchesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BranchesViewController: UITableViewController {
  public var project: Project? {
    didSet {
      if project == nil {
        branches = [Branch]()
      } else {
        branches = project!.branches!.allObjects.sorted({ (a: AnyObject, b: AnyObject) -> Bool in
          return a.name < b.name
        }) as [Branch]
      }
      tableView.reloadData()
    }
  }
  public var branches: [Branch] = [Branch]()

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = ColorScheme().backgroundColor()
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 {
      cell.textLabel.text = "All branches"
    } else {
      let b = branches[indexPath.row]
      cell.textLabel.text = b.name
    }
  }

  public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : branches.count
  }

  public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let d = CI2GoUserDefaults.standardUserDefaults()
    d.selectedProject = project
    if indexPath.section == 1 {
      d.selectedBranch = branches[indexPath.row]
    } else {
      d.selectedBranch = nil
    }
    NSNotificationCenter.defaultCenter().postNotificationName(kCI2GoBranchChangedNotification, object: nil)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
