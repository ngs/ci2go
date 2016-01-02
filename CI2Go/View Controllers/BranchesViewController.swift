//
//  BranchesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

class BranchesViewController: UITableViewController {
    var project: Project? {
        didSet {
            branches = project?.branches.sort() ?? [Branch]()
            tableView.reloadData()
        }
    }
    var branches = [Branch]()

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return ColorScheme().statusBarStyle()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Branches Screen")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorScheme().backgroundColor()
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            cell.textLabel?.text = "All branches"
        } else {
            let b = branches[indexPath.row]
            cell.textLabel?.text = b.name
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : branches.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let d = CI2GoUserDefaults.standardUserDefaults()
        d.selectedProject = project
        var action: String? = nil, label: String? = nil
        if indexPath.section == 1 {
            let branch = branches[indexPath.row]
            d.selectedBranch = branch
            action = "select-branch"
            label = branch.id
        } else if let projectId = project?.id {
            d.selectedBranch = nil
            action = "select-project"
            label = projectId
        } else {
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(kCI2GoBranchChangedNotification, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        let tracker = GAI.sharedInstance().defaultTracker
        let dict = GAIDictionaryBuilder.createEventWithCategory("filter", action: action!, label: label, value: 1).build() as [NSObject : AnyObject]
        tracker.send(dict)
    }
    
}
