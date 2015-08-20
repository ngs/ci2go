//
//  BuildStepsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BuildStepsViewController: BaseTableViewController {
  public var isLoading = false
  public var channel: PTPusherPrivateChannel?
  public var build: Build? = nil {
    didSet(value) {
      if build?.number != nil && build?.project?.repositoryName != nil {
        title = "\(build!.project!.repositoryName!) #\(build!.number)"
        let tracker = GAI.sharedInstance().defaultTracker
        let dict = GAIDictionaryBuilder.createEventWithCategory("build", action: "set", label: build?.apiPath, value: 1).build() as [NSObject : AnyObject]
        tracker.send(dict)
        load()
      } else {
        title = ""
      }
    }
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Build Steps Screen")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    let pusher = AppDelegate.current.pusher
    channel = pusher?.subscribeToPrivateChannelNamed(build?.pusherChannel)
    channel?.bindToEventNamed("newAction", handleWithBlock: { (e/* PTPusherEvent */) -> Void in
      self.handleUpdateAction(e)
    })
    channel?.bindToEventNamed("updateAction", handleWithBlock: { (e/* PTPusherEvent */) -> Void in
      self.handleUpdateAction(e)
    })
    channel?.bindToEventNamed("updateObservables", handleWithBlock: { (e/* PTPusherEvent */) -> Void in
      self.handleUpdateObservables(e)
    })
  }

  func handleUpdateAction(e: PTPusherEvent) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC))),
      dispatch_get_main_queue(), {
        self.tableView.reloadData()
        self.load()
    });
  }

  func handleUpdateObservables(e: PTPusherEvent) {
    channel?.unsubscribe()
  }

  public override func viewWillAppear(animated: Bool) {
    self.updatePredicate()
    super.viewWillAppear(animated)
    let c = NSNotificationCenter.defaultCenter()
    c.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (n: NSNotification!) -> Void in
      dispatch_async(dispatch_get_main_queue(), {
        self.load()
      })
    }
  }

  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    invalidateRefreshTimer()
    NSNotificationCenter.defaultCenter().removeObserver(self)
    channel?.unsubscribe()
    channel = nil
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    let c = NSNotificationCenter.defaultCenter()
    c.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (n: NSNotification!) -> Void in
      dispatch_async(dispatch_get_main_queue(), {
        self.load()
      })
    }
  }

  public override func awakeFromNib() {
    super.awakeFromNib()
    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl!)
  }

  public override func refresh(sender :AnyObject?) {
    tableView.reloadData()
    load()
  }

  private func retryBuild() {
    callAPI("retry", progressMessage: "Queuing Retry", successMessage: "Queued", failureMessage: "Failed")
  }

  private func cancelBuild() {
    callAPI("cancel", progressMessage: "Canceling Build", successMessage: "Canceled", failureMessage: "Failed")
  }

  private func compareChanges() {
    if let url = self.build?.compareURL {
      UIApplication.sharedApplication().openURL(url)
    }
  }

  private func callAPI(path: String, progressMessage: String, successMessage: String, failureMessage: String) {
    let hud = MBProgressHUD(view: self.navigationController?.view)
    self.navigationController?.view.addSubview(hud)
    hud.animationType = MBProgressHUDAnimation.Fade
    hud.dimBackground = true
    hud.labelText = progressMessage
    hud.show(true)
    CircleCIAPISessionManager().POST(build?.apiPath!.stringByAppendingPathComponent(path), parameters: [],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        hud.labelText = successMessage
        hud.customView = UIImageView(image: UIImage(named: "1040-checkmark-hud"))
        hud.mode = MBProgressHUDMode.CustomView
        hud.hide(true, afterDelay: 1)
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
        hud.labelText = failureMessage
        hud.customView = UIImageView(image: UIImage(named: "791-warning-hud"))
        hud.mode = MBProgressHUDMode.CustomView
        hud.hide(true, afterDelay: 1)
    }
  }

  public func load() {
    if isLoading {
      refreshControl?.endRefreshing()
      return
    }
    invalidateRefreshTimer()
    CircleCIAPISessionManager().GET(build?.apiPath!, parameters: [],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        self.refreshControl?.endRefreshing()
        AFNetworkActivityIndicatorManager.sharedManager().incrementActivityCount()
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
          Build.MR_importFromObject(data, inContext: context)
          AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
          return
          },
          completion: { (success: Bool, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              self.isLoading = false
              self.tableView.reloadData()
              if self.build?.lifecycle == "running" {
                self.scheduleNextRefresh()
              }
              AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
            })
            return
        })
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
        self.isLoading = false
    }
  }

  public override func createFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController {
    return BuildAction.MR_fetchAllGroupedBy("type", withPredicate: predicate(), sortedBy: "type,index,nodeIndex", ascending: false, delegate: self, inContext: context)
  }

  public override func predicate() -> NSPredicate? {
    return NSPredicate(format: "buildStep.build.buildID = %@", build!.buildID!)
  }

  public override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }

  public override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let action = fetchedResultsController.objectAtIndexPath(indexPath) as? BuildAction
    let actionCell = cell as? BuildActionTableViewCell
    actionCell?.buildAction = action
//    let hasOutput = action?.outputURL != nil
//    cell.accessoryType = hasOutput ? UITableViewCellAccessoryType.DisclosureIndicator : UITableViewCellAccessoryType.None
//    cell.selectionStyle = hasOutput ? UITableViewCellSelectionStyle.Default : UITableViewCellSelectionStyle.None
  }

  public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
    if let action = sectionInfo.objects[0] as? BuildAction {
      return action.type?.componentsSeparatedByString(": ").last?.humanize
    }
    return nil
  }

//  public override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
//    if let cell = sender as? UITableViewCell {
//      if let indexPath = tableView.indexPathForCell(cell) {
//        if let action = fetchedResultsController.objectAtIndexPath(indexPath) as? BuildAction {
//          return action.outputURL != nil
//        }
//      }
//    }
//    return false
//  }

  public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let cell = sender as? BuildActionTableViewCell
    let nvc = segue.destinationViewController as? UINavigationController
    let vc = nvc?.topViewController as? BuildLogViewController
    vc?.buildAction = cell?.buildAction
    vc?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
    vc?.navigationItem.leftItemsSupplementBackButton = true
  }

  @IBAction func openActionSheet(sender: AnyObject) {
    let asheet = UIActionSheet()
    let lifecycle = self.build?.lifecycle
    asheet.cancelButtonIndex = 0
    if lifecycle != "not_run" {
      asheet.bk_addButtonWithTitle("Rebuild", handler: {
        self.retryBuild()
      })
      asheet.cancelButtonIndex++
    }
    if lifecycle == "running" {
      asheet.bk_addButtonWithTitle("Cancel Build", handler: {
        self.cancelBuild()
      })
      asheet.cancelButtonIndex++
    }
    if self.build?.compareURL != nil {
      asheet.bk_addButtonWithTitle("Compare", handler: {
        self.compareChanges()
      })
      asheet.cancelButtonIndex++
    }
    asheet.addButtonWithTitle("Cancel")
    if let barButtonItem = sender as? UIBarButtonItem {
      asheet.showFromBarButtonItem(barButtonItem, animated: true)
    } else {
      asheet.showInView(self.navigationController?.view)
    }
  }

}
