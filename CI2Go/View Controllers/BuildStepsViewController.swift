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
      if build?.number != nil {
        title = "#\(build!.number)"
        load()
      } else {
        title = ""
      }
    }
  }

  public override func viewDidLoad() {
    scrollToBottom(animated: false)
  }

  public func load() {
    let m = CircleCIAPISessionManager()
    m.GET(build?.apiPath!, parameters: [],
      success: { (op: AFHTTPRequestOperation!, data: AnyObject!) -> Void in
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
          Build.MR_importFromObject(data, inContext: context)
          return
          },
          completion: { (success: Bool, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
              self.isLoading = false
              self.tableView.reloadData()
              self.scrollToBottom(animated: true)
            })
            return
        })
      })
      { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
        self.isLoading = false
    }
  }

  public func scrollToBottom(animated: Bool = false) {
    let h = tableView.frame.size.height
    let w = tableView.frame.size.width
    let y = tableView.contentSize.height - h
    var rectBottom = CGRectMake(0, y, w, h)
    tableView.scrollRectToVisible(rectBottom, animated: animated)
  }

  public override func createFetchedResultsController(context: NSManagedObjectContext) -> NSFetchedResultsController {
    return BuildAction.fetchAllSortedBy("index,nodeIndex", ascending: true, withPredicate: predicate(), groupBy: "type", delegate: self, inContext: context)
  }

  public override func predicate() -> NSPredicate? {
    return NSPredicate(format: "buildStep.build.buildID = %@", build!.buildID!)
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let action = fetchedResultsController.objectAtIndexPath(indexPath) as? BuildAction
    let actionCell = cell as? BuildActionTableViewCell
    actionCell?.buildAction = action
    let hasOutput = action?.hasOutput.boolValue == true
    cell.accessoryType = hasOutput ? UITableViewCellAccessoryType.DisclosureIndicator : UITableViewCellAccessoryType.None
    cell.selectionStyle = hasOutput ? UITableViewCellSelectionStyle.Default : UITableViewCellSelectionStyle.None
  }

  public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    if let action = sectionInfo.objects[0] as? BuildAction {
      return action.type
    }
    return nil
  }

  public override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
    if let cell = sender as? UITableViewCell {
      if let indexPath = tableView.indexPathForCell(cell) {
        if let action = fetchedResultsController.objectAtIndexPath(indexPath) as? BuildAction {
          return action.hasOutput.boolValue
        }
      }
    }
    return false
  }

  public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let cell = sender as? BuildActionTableViewCell
    let vc = segue.destinationViewController as? BuildLogViewController
    vc?.buildAction = cell?.buildAction
  }
  
}
