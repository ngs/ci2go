//
//  BuildLogViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import AFNetworking
import MagicalRecord
import MBProgressHUD

public class BuildLogViewController: UIViewController {
  @IBOutlet weak var textView: BuildLogTextView!
  public var buildAction: BuildAction? = nil {
    didSet {
      title = buildAction?.name
      let tracker = GAI.sharedInstance().defaultTracker
      let dict = GAIDictionaryBuilder.createEventWithCategory("build-log", action: "set", label: buildAction?.type, value: 1).build() as [NSObject : AnyObject]
      tracker.send(dict)
    }
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "Build Log Screen")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    load()
  }

  func load() {
    if buildAction?.outputURL != nil {
      if let cache = buildAction?.logData {
        self.textView.logText = cache
        return
      }
      AFHTTPSessionManager().GET(buildAction!.outputURLString!, parameters: [],
        success: { (task: NSURLSessionDataTask!, res: AnyObject!) -> Void in
          if let ar = res as? NSArray {
            if let dict = ar.firstObject as? NSDictionary {
              if let msg = dict["message"] as? String {
                self.textView.logText = msg
                self.buildAction?.logData = msg
              }
            }
          }
        },
        failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
        }
      )
    }
  }
  
}
