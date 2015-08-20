//
//  BuildLogViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BuildLogViewController: UIViewController {
  @IBOutlet weak var textView: BuildLogTextView!
  public var channel: PTPusherPrivateChannel?
  var logString: String?
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
    let build = buildAction?.buildStep.build
    tracker.set(kGAIScreenName, value: "Build Log Screen")
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    if buildAction?.outputURL == nil {
      let pusher = AppDelegate.current.pusher
      channel = pusher?.subscribeToPrivateChannelNamed(build?.pusherChannel)
      channel?.bindToEventNamed("appendAction", handleWithBlock: { (e) -> Void in
        self.handleAppendAction(e)
      })
      channel?.bindToEventNamed("updateAction", handleWithBlock: { (e) -> Void in
        self.handleUpdateAction(e)
      })
    } else {
      load()
    }
  }

  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    channel?.unsubscribe()
  }

  func handleUpdateAction(e: PTPusherEvent) {
    let data = e.data as? [NSObject : AnyObject]
    if data != nil && data!["has_output"] as? Bool == true {
      buildAction?.MR_importValuesForKeysWithObject(data)
      channel?.unsubscribe()
    }
  }

  func handleAppendAction(e: PTPusherEvent) {
    let data = e.data as? Array<[NSObject : AnyObject]>
    if data == nil { return }
    for outItem in data! {
      if let out = outItem["out"] as? [NSObject : AnyObject] {
        if let output = out["message"] as? String {
          logString = (logString == nil ? "" : logString!) + output
          self.textView.logText = logString
          // TODO: scroll to bottom
        }
      }
    }
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
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
