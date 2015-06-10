//
//  ProjectsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class ProjectsViewController: UITableViewController {

  public var projects: [Project] = [Project]()

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = ColorScheme().backgroundColor()
    refresh()
  }

  public func refresh() {
    projects = Project.MR_findAll().sorted({ (a: AnyObject, b: AnyObject) -> Bool in
      let prjA = a as! Project, prjB = b as! Project
      return prjA.projectID < prjB.projectID
    }) as! [Project]
    tableView.reloadData()
  }

  @IBAction func cancelButtonTapped(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 {
      cell.textLabel?.text = "All projects"
    } else {
      let project = projects[indexPath.row]
      cell.textLabel?.text = project.repositoryName
      cell.detailTextLabel?.text = project.username
      cell.detailTextLabel?.alpha = 0.5
    }
  }

  public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell\(indexPath.section)") as! UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Projects Screen")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    CircleCIAPISessionManager().GET("projects", parameters: [],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        AFNetworkActivityIndicatorManager.sharedManager().incrementActivityCount()
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
          if let ar = data as? NSArray {
            Project.MR_importFromArray(ar as [AnyObject], inContext: context)
          }
          AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
          }, completion: { (success: Bool, error: NSError!) -> Void in
            AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              self.refresh()
            })
        })
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
    }
  }

  public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : projects.count
  }

  public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let vc = segue.destinationViewController as? BranchesViewController
    let cell = sender as? UITableViewCell
    if vc != nil && cell != nil {
      if let indexPath = tableView.indexPathForCell(cell!) {
        vc?.project = projects[indexPath.row]
      }
    }
  }

  public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 {
      let d = CI2GoUserDefaults.standardUserDefaults()
      d.selectedProject = nil
      d.selectedBranch = nil
      NSNotificationCenter.defaultCenter().postNotificationName(kCI2GoBranchChangedNotification, object: nil)
      self.dismissViewControllerAnimated(true, completion: nil)
      let tracker = GAI.sharedInstance().defaultTracker
      let dict = GAIDictionaryBuilder.createEventWithCategory("filter", action: "select-project", label: "<none>" , value: 0).build() as [NSObject : AnyObject]
      tracker.send(dict)
    }
  }
  
}
