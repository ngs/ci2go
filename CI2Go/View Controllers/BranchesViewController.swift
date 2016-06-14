//
//  BranchesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import Crashlytics

class BranchesViewController: UITableViewController {
    let disposeBag = DisposeBag()
    var project: Project? {
        didSet {
            self.title = project?.path
        }
    }

    lazy var realm: Realm = {
        return try! Realm()
    }()

    lazy var rrc: RealmResultsController<Branch, Branch> = {
        let predicate: NSPredicate
        if let project = self.project {
            predicate = NSPredicate(format: "id BEGINSWITH %@", project.id)
        } else {
            predicate = NSPredicate(value: true)
        }
        let sd = SortDescriptor(property: "name")
        let req = RealmRequest<Branch>(predicate: predicate, realm: self.realm, sortDescriptors: [sd])
        let rrc = try! RealmResultsController<Branch, Branch>(request: req, sectionKeyPath: nil)
        rrc.delegate = self
        return rrc
    }()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Branches Screen")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        Answers.logContentViewWithName("Branches", contentType: "Project", contentId: project?.id, customAttributes: [:])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorScheme().backgroundColor()
        self.rrc.performFetch()
        self.tableView.reloadData()
        Project.getAll().subscribe().addDisposableTo(disposeBag)
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            cell.textLabel?.text = "All branches"
        } else {
            let b = rrc.objectAt(NSIndexPath(forRow: indexPath.row, inSection: 0))
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
        return section == 0 ? 1 : rrc.numberOfObjectsAt(0)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let d = CI2GoUserDefaults.standardUserDefaults()
        d.selectedProject = project
        var action: String? = nil, label: String? = nil
        if indexPath.section == 1 {
            let branch = rrc.objectAt(NSIndexPath(forRow: indexPath.row, inSection: 0))
            d.selectedBranch = branch
            action = "select-branch"
            label = branch.id
            Answers.logCustomEventWithName("Select Branch", customAttributes: ["branch": branch.id])
        } else if let projectId = project?.id {
            d.selectedBranch = nil
            action = "select-project"
            label = projectId
            Answers.logCustomEventWithName("Select Project", customAttributes: ["project": projectId])
        } else {
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName(kCI2GoBranchChangedNotification, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        let tracker = GAI.sharedInstance().defaultTracker
        let dict = GAIDictionaryBuilder.createEventWithCategory("filter", action: action!, label: label, value: 1).build() as [NSObject : AnyObject]
        tracker.send(dict)
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
