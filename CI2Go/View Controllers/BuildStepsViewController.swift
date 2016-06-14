//
//  BuildStepsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import MBProgressHUD
import FileKit
import RxSwift
import RealmSwift
import RxSwift
import SafariServices
import Crashlytics

class BuildStepsViewController: UITableViewController {

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

    var isLoading = false, scrollAfterRefresh = false

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
        Answers.logContentViewWithName("Build Steps", contentType: "Build", contentId: build?.id, customAttributes: [:])
        let c = NSNotificationCenter.defaultCenter()
        c.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (n: NSNotification) -> Void in
            self.refresh(n)
        }
    }

    var pusherSubscription: Disposable?

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard let build = build else { return }
        refresh(nil)
        pusherSubscription = AppDelegate.current.pusherClient.subscribeBuild(build).subscribeNext {
            self.scrollAfterRefresh = true
            self.refresh(nil)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        pusherSubscription?.dispose()
        pusherSubscription = nil
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

    private func browseArtifacts(sender: AnyObject? = nil) {
        guard let build = build else { return }
        let realm = try! Realm()
        if let artifactsPath = realm.objects(BuildArtifact.self).filter("build == %@", build).first?.browseEntryPointPath where artifactsPath.exists {
            openFileBrowser(artifactsPath)
            return
        }
        let hud = MBProgressHUD(view: self.navigationController?.view)
        self.navigationController?.view.addSubview(hud)
        hud.animationType = MBProgressHUDAnimation.Fade
        hud.dimBackground = true
        hud.labelText = "Downloading File List"
        hud.show(true)
        build.getArtifacts().subscribe(
            onNext: { artifacts in
                hud.hide(true)
                if let artifactsPath = artifacts.first?.browseEntryPointPath {
                    self.openFileBrowser(artifactsPath, sender: sender)
                }
            },
            onError:  { _ in
                hud.labelText = "Failed to Download File List"
                hud.customView = UIImageView(image: UIImage(named: "791-warning-hud"))
                hud.mode = MBProgressHUDMode.CustomView
                hud.hide(true, afterDelay: 1)
            }
        ).addDisposableTo(disposeBag)
    }

    private func openFileBrowser(path: Path, sender: AnyObject? = nil) {
        let children = path.children()
        let excludesFileExtensions = [kCI2GoWeblocExtension, kCI2GoDownloadExtension]
        if children.count == 1 {
            let fb = FileBrowser(initialPath: children.first!.URL)
            fb.excludesFileExtensions = excludesFileExtensions
            self.presentViewController(fb, animated: true, completion: nil)
        } else {
            let av = UIAlertController(title: "Select Node", message: nil, preferredStyle: .ActionSheet)
            children.forEach { child in
                av.addAction(UIAlertAction(title: "Container \(child.fileName)",
                    style: .Default, handler: { _ in
                        let fb = FileBrowser(initialPath: child.URL)
                        fb.excludesFileExtensions = excludesFileExtensions
                        self.presentViewController(fb, animated: true, completion: nil)
                }))
            }
            presentAlertController(av, sender: sender)
        }
    }

    private func presentAlertController(av: UIAlertController, sender: AnyObject?) {
        av.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        if let barButtonItem = sender as? UIBarButtonItem, popover = av.popoverPresentationController {
            popover.barButtonItem = barButtonItem
        }
        presentViewController(av, animated: true, completion: {})
        let c = UIColor.darkTextColor()
        av.view.tintColor = c
        av.view.subviewsForClass(UILabel.self).forEach { l in
            guard let l = l as? UILabel else { return }
            l.textColor = c
            l.tintColor = c
        }
        av.view.setNeedsDisplay()
    }

    private func retryBuild() {
        callAPI(.Retry, progressMessage: "Queuing Retry", successMessage: "Queued", failureMessage: "Failed")
    }

    private func clearCacheAndRetryBuild() {
        callAPI(.Retry, clearCache: true, progressMessage: "Queuing Retry", successMessage: "Queued", failureMessage: "Failed")
    }

    private func cancelBuild() {
        callAPI(.Retry, progressMessage: "Canceling Build", successMessage: "Canceled", failureMessage: "Failed")
    }

    private func openSafari(URL: NSURL) {
        let vc = SFSafariViewController(URL: URL, entersReaderIfAvailable: true)
        self.presentViewController(vc, animated: true, completion: nil)
        vc.navigationController?.navigationBar.barTintColor = ColorScheme().backgroundColor()
    }

    private func callAPI(path: Build.APIAction, clearCache: Bool = false, progressMessage: String, successMessage: String, failureMessage: String) {
        guard let build = build else { return }
        let hud = MBProgressHUD(view: self.navigationController?.view)
        self.navigationController?.view.addSubview(hud)
        hud.animationType = MBProgressHUDAnimation.Fade
        hud.dimBackground = true
        hud.labelText = progressMessage
        hud.show(true)
        build.post(path, clearCache: clearCache).subscribe(
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
        let hasOutput = action.hasOutput || action.status == .Running
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
            let a = rrc.objectAt(indexPath)
            return a.hasOutput || a.status == .Running
        }
        return false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let nvc = segue.destinationViewController as? UINavigationController else { return }
        switch nvc.topViewController {
        case let vc as BuildLogViewController:
            let cell = sender as? BuildActionTableViewCell
            vc.buildAction = cell?.buildAction
            break
        case let vc as TextViewController:
            vc.text = sender as? String
            break
        default:
            break
        }
        let ni = nvc.topViewController?.navigationItem
        ni?.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        ni?.leftItemsSupplementBackButton = true
    }

    func scrollToBottom(animated: Bool = false) {
        let section = rrc.numberOfSections - 1
        let row = rrc.numberOfObjectsAt(section) - 1
        let diff = tableView.bounds.height + tableView.contentOffset.y - tableView.contentSize.height
        if section >= 0 && row >= 0 && diff < tableView.rowHeight {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: row, inSection: section), atScrollPosition: .Bottom, animated: animated)
        }
    }

    @IBAction func openActionSheet(sender: AnyObject) {
        guard let lifecycle = self.build?.lifecycle else { return }
        let av = UIAlertController()
        if lifecycle != .NotRun && lifecycle != .NotRunning {
            av.addAction(UIAlertAction(title: "Rebuild", style: .Default, handler: { _ in
                self.retryBuild()
            }))
            av.addAction(UIAlertAction(title: "Rebuild without Cache", style: .Default, handler: { _ in
                self.clearCacheAndRetryBuild()
            }))
        }
        if lifecycle == .Running || lifecycle == .NotRunning {
            av.addAction(UIAlertAction(title: "Cancel Build", style: .Default, handler: { _ in
                self.cancelBuild()
            }))
        }
        if let URL = self.build?.compareURL {
            av.addAction(UIAlertAction(title: "Compare", style: .Default, handler: { _ in
                self.openSafari(URL)
            }))
        }
        if let yaml = self.build?.circleYAML where !yaml.isEmpty {
            av.addAction(UIAlertAction(title: "View circle.yml", style: .Default, handler: { _ in
                self.openCircleYAML(yaml)
            }))
        }
        if build?.hasArtifacts == true {
            av.addAction(UIAlertAction(title: "Browse Artifacts", style: .Default, handler: { _ in
                self.browseArtifacts()
            }))
        }
        presentAlertController(av, sender: sender)
    }

    func openCircleYAML(yaml: String) {
        print(yaml)
        self.performSegueWithIdentifier("showYamlSegue", sender: yaml)
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
        print("🎁 didChangeObject '\((object as! BuildAction).id)' from: [\(oldIndexPath.section):\(oldIndexPath.row)] to: [\(newIndexPath.section):\(newIndexPath.row)] --> \(changeType) \(rrc.numberOfObjectsAt(newIndexPath.section)) \(rrc.numberOfSections))")
        pendingChanges.append(RRCPendingChange(
            sectionIndex: nil, oldIndexPath: oldIndexPath,
            newIndexPath: newIndexPath, changeType: changeType))
    }

    func didChangeSection<U>(controller: AnyObject, section: RealmSection<U>, index: Int, changeType: RealmResultsChangeType) {
        guard controller === self.rrc else { return }
        print("💈 didChangeSection \(index)/\(rrc.numberOfSections) --> \(changeType)")
        pendingChanges.append(RRCPendingChange(
            sectionIndex: index, oldIndexPath: nil,
            newIndexPath: nil, changeType: changeType))
    }

    func didChangeResults(controller: AnyObject) {
        guard controller === self.rrc else { return }
        print("🙃 didChangeResults \(self.numberOfSectionsInTableView(tableView))")
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
        if scrollAfterRefresh {
            scrollToBottom(false)
        }
        scrollAfterRefresh = false
    }
}
