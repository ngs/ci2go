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
import RxCocoa

class BuildsViewController: UITableViewController, RealmResultsControllerDelegate {

    lazy var realm: Realm = {
        return try! Realm()
    }()

    var rrc: RealmResultsController<Build, Build>?

    func buildRRC() -> RealmResultsController<Build, Build> {
        let def = CI2GoUserDefaults.standardUserDefaults()
        let sd = SortDescriptor(property: "queuedAt", ascending: false)
        let req = RealmRequest<Build>(predicate: def.buildsPredicate, realm: self.realm, sortDescriptors: [sd])
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

    var pusherSubscription: Disposable?

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
            pusherSubscription = AppDelegate.current.pusherClient.subscribeRefresh().subscribeNext {
                self.refresh(nil)
            }
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
        pusherSubscription?.dispose()
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

    var pendingChanges = [RRCPendingChange]()

    func willChangeResults(controller: AnyObject) {
        guard controller === self.rrc else { return }
        print("😇 willChangeResults")
        pendingChanges.removeAll()
    }

    func didChangeObject<U>(controller: AnyObject, object: U, oldIndexPath: NSIndexPath, newIndexPath: NSIndexPath, changeType: RealmResultsChangeType) {
        guard controller === self.rrc else { return }
        pendingChanges.append(RRCPendingChange(
            sectionIndex: nil, oldIndexPath: oldIndexPath,
            newIndexPath: newIndexPath, changeType: changeType))
    }

    func didChangeSection<U>(controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
        guard controller === self.rrc else { return }
        pendingChanges.append(RRCPendingChange(
            sectionIndex: index, oldIndexPath: nil,
            newIndexPath: nil, changeType: changeType))
    }

    func didChangeResults(controller: AnyObject) {
        guard controller === self.rrc else { return }
        tableView.beginUpdates()
        pendingChanges.forEach { update in
            if let newIndexPath = update.newIndexPath, oldIndexPath = update.oldIndexPath {
                switch update.changeType {
                case .Delete:
                    tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                    break
                case .Insert:
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                    break
                case .Move:
                    tableView.deleteRowsAtIndexPaths([oldIndexPath], withRowAnimation: .Automatic)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                    break
                case .Update:
                    tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                    break
                }
            } else if let sectionIndex = update.sectionIndex {
                let indexSet = NSIndexSet(index: sectionIndex)
                switch update.changeType {
                case .Delete:
                    tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
                    break
                case .Insert:
                    tableView.insertSections(indexSet, withRowAnimation: .Automatic)
                    break
                case .Update:
                    tableView.reloadSections(indexSet, withRowAnimation: .Automatic)
                    break
                default:
                    break
                }
            }
        }
        pendingChanges.removeAll()
        tableView.endUpdates()
    }

}
