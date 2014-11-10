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
  public var buildAction: BuildAction? = nil {
    didSet {
      title = buildAction?.name
    }
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    load()
  }

  func load() {
    if buildAction?.outputURL != nil {
      AFHTTPSessionManager().GET(buildAction!.outputURLString!, parameters: [],
        success: { (task: NSURLSessionDataTask!, res: AnyObject!) -> Void in
          if let ar = res as? NSArray {
            if let dict = ar.firstObject as? NSDictionary {
              if let msg = dict["message"] as? String {
                self.textView.logText = msg
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
