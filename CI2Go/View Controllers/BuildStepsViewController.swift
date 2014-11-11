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
  public var build: Build? = nil {
    didSet(value) {
      if build?.number != nil && build?.project?.repositoryName != nil {
        title = "\(build!.project!.repositoryName!) #\(build!.number)"
        load()
      } else {
        title = ""
      }
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
    hud.animationType = MBProgressHUDAnimationFade
    hud.dimBackground = true
    hud.labelText = progressMessage
    hud.show(true)
    CircleCIAPISessionManager().POST(build?.apiPath!.stringByAppendingPathComponent(path), parameters: [],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        hud.labelText = successMessage
        hud.customView = UIImageView(image: UIImage(named: "1040-checkmark-hud"))
        hud.mode = MBProgressHUDModeCustomView
        hud.hide(true, afterDelay: 1)
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
        hud.labelText = failureMessage
        hud.customView = UIImageView(image: UIImage(named: "791-warning-hud"))
        hud.mode = MBProgressHUDModeCustomView
        hud.hide(true, afterDelay: 1)
    }
  }

  public func load() {
    if isLoading {
      refreshControl?.endRefreshing()
      return
    }
    CircleCIAPISessionManager().GET(build?.apiPath!, parameters: [],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        self.refreshControl?.endRefreshing()
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
          Build.MR_importFromObject(data, inContext: context)
          return
          },
          completion: { (success: Bool, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              self.isLoading = false
              self.tableView.reloadData()
              if self.build?.lifecycle == "running" {
                self.scheduleNextRefresh()
              }
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

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let action = fetchedResultsController.objectAtIndexPath(indexPath) as? BuildAction
    let actionCell = cell as? BuildActionTableViewCell
    actionCell?.buildAction = action
    let hasOutput = action?.outputURL != nil
    cell.accessoryType = hasOutput ? UITableViewCellAccessoryType.DisclosureIndicator : UITableViewCellAccessoryType.None
    cell.selectionStyle = hasOutput ? UITableViewCellSelectionStyle.Default : UITableViewCellSelectionStyle.None
  }

  public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    if let action = sectionInfo.objects[0] as? BuildAction {
      return action.type?.componentsSeparatedByString(": ").last?.humanize
    }
    return nil
  }

  public override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
    if let cell = sender as? UITableViewCell {
      if let indexPath = tableView.indexPathForCell(cell) {
        if let action = fetchedResultsController.objectAtIndexPath(indexPath) as? BuildAction {
          return action.outputURL != nil
        }
      }
    }
    return false
  }

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
