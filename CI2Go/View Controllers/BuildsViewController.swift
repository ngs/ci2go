//
//  BuildsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RealmResultsController
import RxSwift

class BuildsViewController: UITableViewController, RealmResultsControllerDelegate {

    lazy var realm: Realm = {
        return try! Realm()
    }()

    var rrc: RealmResultsController<Build, Build>?

    func buildRRC() -> RealmResultsController<Build, Build> {
        let predicate: NSPredicate
        let def = CI2GoUserDefaults.standardUserDefaults()
        let baseQuery = "id != %@ AND branch != nil AND project != nil"
        if let branch = def.selectedBranch {
            predicate = NSPredicate(format: "branch.id == %@ AND \(baseQuery)", branch.id, "")
        } else if let project = def.selectedProject {
            predicate = NSPredicate(format: "project.id == %@ AND \(baseQuery)", project.id, "")
        } else {
            predicate = NSPredicate(format: baseQuery, "")
        }
        let sd = SortDescriptor(property: "queuedAt", ascending: false)
        let req = RealmRequest<Build>(predicate: predicate, realm: self.realm, sortDescriptors: [sd])
        let rrc = try! RealmResultsController<Build, Build>(request: req, sectionKeyPath: nil)
        rrc.delegate = self
        return rrc
    }

    func updateRRC(sender: AnyObject? = nil) {
        let def = CI2GoUserDefaults.standardUserDefaults()
        if let branch = def.selectedBranch, project = branch.project {
            self.navigationItem.prompt = "\(project.path) (\(branch.name))"
        } else if let project = def.selectedProject {
            self.navigationItem.prompt = project.path
        } else {
            self.navigationItem.prompt = nil
        }
        self.rrc?.delegate = nil
        self.rrc = self.buildRRC()
        self.refresh(sender)
    }

    private var refreshTimer: NSTimer? = nil

    let disposeBag = DisposeBag()

    var offset = 0, isLoading = false
    let limit = 30

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.rx_controlEvent(.ValueChanged).subscribeNext {
            self.refresh(self.refreshControl)
            }.addDisposableTo(disposeBag)
        tableView.addSubview(refreshControl!)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.backgroundColor = ColorScheme().backgroundColor()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = NSProcessInfo().environment["TEST"] {
            return
        }
        let tracker = GAI.sharedInstance().defaultTracker
        let d = CI2GoUserDefaults.standardUserDefaults()
        if !d.isLoggedIn {
            tracker.set(kGAIScreenName, value: "Initial Launch")
            performSegueWithIdentifier("showSettings", sender: nil)
        } else {
            tracker.set(kGAIScreenName, value: "Builds Screen")
            self.updateRRC()
        }
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let c = NSNotificationCenter.defaultCenter()
        c.addObserverForName(kCI2GoBranchChangedNotification, object: nil, queue: nil) { (n: NSNotification) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.updateRRC(n)
            })
        }
        c.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (n: NSNotification) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.refresh(n)
            })
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? BuildStepsViewController else { return }
        switch sender {
        case let cell as BuildTableViewCell:
            vc.build = cell.build
            break
        case let build as Build:
            vc.build = build
            break
        default:
            break
        }
    }

    // MARK: - UITableViewController

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.rrc?.numberOfSections ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = rrc?.numberOfObjectsAt(section) ?? 0
        print("table --------------------- \(n)")
        return n
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row >= offset && !isLoading {
            self.load(true)
        }
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        let top = scrollView.frame.origin.y
        let scrollTop = scrollView.contentOffset.y
        let diff = contentHeight - scrollTop - top
        if diff < height && rrc?.numberOfObjectsAt(0) > 0 {
            load(true)
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? BuildTableViewCell
            , build = rrc?.objectAt(indexPath) else { return }
        cell.build = build
    }

    func load(more: Bool) {
        guard !isLoading else {
            refreshControl?.endRefreshing()
            return
        }
        if more {
            offset += limit
        } else {
            offset = 0
        }
        isLoading = true
        Build.getList(offset: offset, limit: limit).subscribe(
            onNext: { _ in
                self.refreshControl?.endRefreshing()
                self.isLoading = false
            },
            onError: { _ in
                self.refreshControl?.endRefreshing()
                self.isLoading = false
            }
            ).addDisposableTo(disposeBag)
    }

    func refresh(sender :AnyObject?) {
        self.rrc?.performFetch()
        self.tableView.reloadData()
        self.load(false)
    }

    // MARK: - RealmResultsControllerDelegate

    func willChangeResults(controller: AnyObject) {
        tableView.beginUpdates()
    }

    func didChangeObject<U>(controller: AnyObject, object: U, oldIndexPath: NSIndexPath, newIndexPath: NSIndexPath, changeType: RealmResultsChangeType) {
        switch changeType {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            break
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
            break
        case .Move:
            tableView.deleteRowsAtIndexPaths([oldIndexPath], withRowAnimation: .None)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .None)
            break
        case .Update:
            tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: .None)
            break
        }
    }

    func didChangeSection<U>(controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
        switch changeType {
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
            break
        case .Insert:
            tableView.insertSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
            break
        default:
            break
        }
    }
    
    func didChangeResults(controller: AnyObject) {
        tableView.endUpdates()
    }
    
}
