//
//  BuildStepsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import MBProgressHUD
import RxSwift
import RealmSwift
import RealmResultsController
import RxSwift
import SafariServices

class BuildStepsViewController: UITableViewController, RealmResultsControllerDelegate {

    var build: Build?
    let disposeBag = DisposeBag()

    lazy var realm: Realm = {
        return try! Realm()
    }()

    lazy var rrc: RealmResultsController<BuildAction, BuildAction> = {
        let predicate: NSPredicate
        if let buildId = self.build?.id {
            predicate = NSPredicate(format: "id BEGINSWITH %@", "\(buildId):")
        } else {
            predicate = NSPredicate(value: false)
        }
        let sd = [
            SortDescriptor(property: "actionType"),
            SortDescriptor(property: "stepNumber")
        ]
        let req = RealmRequest<BuildAction>(predicate: predicate, realm: self.realm, sortDescriptors: sd)
        let rrc = try! RealmResultsController<BuildAction, BuildAction>(request: req, sectionKeyPath: "actionType")
        rrc.delegate = self
        return rrc
    }()

    var isLoading = false

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let buildNum = build?.number, repoName = build?.project?.repositoryName {
            title = "\(repoName) #\(buildNum)"
            let tracker = GAI.sharedInstance().defaultTracker
            let dict = GAIDictionaryBuilder.createEventWithCategory("build", action: "set", label: build?.apiPath, value: 1).build() as [NSObject : AnyObject]
            tracker.send(dict)
        } else {
            title = ""
        }
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Build Steps Screen")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        let c = NSNotificationCenter.defaultCenter()
        c.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (n: NSNotification) -> Void in
            self.refresh(n)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh(nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        guard let refreshControl = refreshControl else { return }
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    }

    func refresh(sender :AnyObject?) {
        rrc.performFetch()
        tableView.reloadData()
        load()
    }

    private func retryBuild() {
        callAPI("retry", progressMessage: "Queuing Retry", successMessage: "Queued", failureMessage: "Failed")
    }

    private func cancelBuild() {
        callAPI("cancel", progressMessage: "Canceling Build", successMessage: "Canceled", failureMessage: "Failed")
    }

    private func openSafari(URL: NSURL) {
        let vc = SFSafariViewController(URL: URL, entersReaderIfAvailable: true)
        self.presentViewController(vc, animated: true, completion: nil)
        vc.navigationController?.navigationBar.barTintColor = ColorScheme().backgroundColor()
    }

    private func callAPI(path: String, progressMessage: String, successMessage: String, failureMessage: String) {
        guard let build = build else { return }
        let hud = MBProgressHUD(view: self.navigationController?.view)
        self.navigationController?.view.addSubview(hud)
        hud.animationType = MBProgressHUDAnimation.Fade
        hud.dimBackground = true
        hud.labelText = progressMessage
        hud.show(true)
        build.post(path).subscribe(
            onNext: { build in
                hud.labelText = successMessage
                hud.customView = UIImageView(image: UIImage(named: "1040-checkmark-hud"))
                hud.mode = MBProgressHUDMode.CustomView
                hud.hide(true, afterDelay: 1)
                self.refresh(nil)
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("BuildStepsViewController") as? BuildStepsViewController where build != self.build {
                    vc.build = build
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            },
            onError:  { _ in
                hud.labelText = failureMessage
                hud.customView = UIImageView(image: UIImage(named: "791-warning-hud"))
                hud.mode = MBProgressHUDMode.CustomView
                hud.hide(true, afterDelay: 1)
            }
            ).addDisposableTo(disposeBag)
    }

    func load() {
        if isLoading {
            refreshControl?.endRefreshing()
            return
        }
        self.isLoading = true
        self.build?.getSteps().subscribe(
            onNext: { _ in
                self.isLoading = false
                self.refreshControl?.endRefreshing()
            },
            onError: { _ in
                self.isLoading = false
                self.refreshControl?.endRefreshing()
            }
            ).addDisposableTo(disposeBag)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rrc.numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rrc.numberOfObjectsAt(section)
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(), s = ColorScheme()
        let label = UILabel(frame: CGRectMake(0, 0, 0, 30))
        label.backgroundColor = UIColor.clearColor()
        label.textColor = s.foregroundColor()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.font = UIFont(name: "Helvetica Neue Bold Italic", size: 14)
        label.sizeToFit()
        label.frame = CGRect(origin: CGPointMake(10, 7), size: label.frame.size)
        v.addSubview(label)
        v.backgroundColor = s.backgroundColor()?.colorWithAlphaComponent(0.7)
        return v
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let action = rrc.objectAt(indexPath)
        let actionCell = cell as? BuildActionTableViewCell
        actionCell?.buildAction = action
        let hasOutput = action.hasOutput
        cell.accessoryType = hasOutput ? UITableViewCellAccessoryType.DisclosureIndicator : UITableViewCellAccessoryType.None
        cell.selectionStyle = hasOutput ? UITableViewCellSelectionStyle.Default : UITableViewCellSelectionStyle.None
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if rrc.numberOfObjectsAt(section) > 0 {
            let action = rrc.objectAt(NSIndexPath(forRow: 0, inSection: section))
            return action.actionName
        }
        return nil
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) {
            return rrc.objectAt(indexPath).hasOutput
        }
        return false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as? BuildActionTableViewCell
        let nvc = segue.destinationViewController as? UINavigationController
        let vc = nvc?.topViewController as? BuildLogViewController
        vc?.buildAction = cell?.buildAction
        vc?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        vc?.navigationItem.leftItemsSupplementBackButton = true
    }

    @IBAction func openActionSheet(sender: AnyObject) {
        guard let lifecycle = self.build?.lifecycle else { return }
        let av = UIAlertController()
        if lifecycle != .NotRun {
            av.addAction(UIAlertAction(title: "Rebuild", style: .Default, handler: { _ in
                self.retryBuild()
            }))
        }
        if lifecycle == .Running {
            av.addAction(UIAlertAction(title: "Cancel Build", style: .Default, handler: { _ in
                self.cancelBuild()
            }))
        }
        if let URL = self.build?.compareURL {
            av.addAction(UIAlertAction(title: "Compare", style: .Default, handler: { _ in
                self.openSafari(URL)
            }))
        }
        av.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        if let barButtonItem = sender as? UIBarButtonItem, popover = av.popoverPresentationController {
            popover.barButtonItem = barButtonItem
        }
        presentViewController(av, animated: true, completion: nil)
    }


    // MARK: - RealmResultsControllerDelegate

    func willChangeResults(controller: AnyObject) {
        print("😇 willChangeResults")
        tableView.beginUpdates()
    }

    func didChangeObject<U>(controller: AnyObject, object: U, oldIndexPath: NSIndexPath, newIndexPath: NSIndexPath, changeType: RealmResultsChangeType) {
        print("🎁 didChangeObject '\((object as! BuildAction).id)' from: [\(oldIndexPath.section):\(oldIndexPath.row)] to: [\(newIndexPath.section):\(newIndexPath.row)] --> \(changeType) \(rrc.numberOfObjectsAt(newIndexPath.section)) \(rrc.numberOfSections))")
        switch changeType {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
            break
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
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
        print("💈 didChangeSection \(index)/\(rrc.numberOfSections) --> \(changeType)")
        switch changeType {
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: index), withRowAnimation: .None)
            break
        case .Insert:
            tableView.insertSections(NSIndexSet(index: index), withRowAnimation: .None)
            break
        default:
            break
        }
    }

    func didChangeResults(controller: AnyObject) {
        print("🙃 didChangeResults")
        self.tableView.endUpdates()
    }
}
