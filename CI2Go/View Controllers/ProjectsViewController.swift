//
//  ProjectsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import MBProgressHUD
import RealmSwift
import RealmResultsController
import RxSwift

class ProjectsViewController: UITableViewController, RealmResultsControllerDelegate {

    let disposeBag = DisposeBag()

    lazy var realm: Realm = {
        return try! Realm()
    }()

    lazy var rrc: RealmResultsController<Project, Project> = {
        let predicate = NSPredicate(value: true)
        let sd = SortDescriptor(property: "id")
        let req = RealmRequest<Project>(predicate: predicate, realm: self.realm, sortDescriptors: [sd])
        let rrc = try! RealmResultsController<Project, Project>(request: req, sectionKeyPath: nil)
        rrc.delegate = self
        return rrc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorScheme().backgroundColor()
        self.rrc.performFetch()
        self.tableView.reloadData()
        Project.getAll().subscribe().addDisposableTo(disposeBag)
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            cell.textLabel?.text = "All projects"
            cell.accessoryType = .None
        } else {
            let project = rrc.objectAt(NSIndexPath(forRow: indexPath.row, inSection: 0))
            cell.textLabel?.text = project.repositoryName
            cell.detailTextLabel?.text = project.username
            cell.detailTextLabel?.alpha = 0.5
            cell.accessoryType = .DisclosureIndicator
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell\(indexPath.section)")!
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Projects Screen")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : rrc.numberOfObjectsAt(0)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as? BranchesViewController
        let cell = sender as? UITableViewCell
        if vc != nil && cell != nil {
            if let indexPath = tableView.indexPathForCell(cell!) {
                vc?.project = rrc.objectAt(NSIndexPath(forRow: indexPath.row, inSection: 0))
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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

    // MARK: - RealmResultsControllerDelegate

    func willChangeResults(controller: AnyObject) {
        tableView.beginUpdates()
    }

    func didChangeObject<U>(controller: AnyObject, object: U, var oldIndexPath: NSIndexPath, var newIndexPath: NSIndexPath, changeType: RealmResultsChangeType) {
        oldIndexPath = NSIndexPath(forRow: oldIndexPath.row, inSection: 1)
        newIndexPath = NSIndexPath(forRow: newIndexPath.row, inSection: 1)
        switch changeType {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            break
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            break
        case .Move:
            tableView.moveRowAtIndexPath(oldIndexPath, toIndexPath: newIndexPath)
            break
        case .Update:
            tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            break
        }
    }

    func didChangeSection<U>(controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
        switch changeType {
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
            break
        case .Insert:
            tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
            break
        default:
            break
        }
    }

    func didChangeResults(controller: AnyObject) {
        tableView.endUpdates()
    }
    
}
