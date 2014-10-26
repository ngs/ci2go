//
//  BuildsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BuildsViewController: UITableViewController {
  
  public override func viewDidAppear(animated: Bool) {
    let d = CI2GoUserDefaults.standardUserDefaults()
    if !(d.circleCIAPIToken?.length > 0) {
      performSegueWithIdentifier("showSettings", sender: nil)
    }
  }

}
