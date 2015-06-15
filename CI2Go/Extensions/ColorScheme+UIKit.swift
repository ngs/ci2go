//
//  ColorScheme+UIKit.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import Foundation
import UIKit

extension ColorScheme {

  public func apply() {
    let bg = backgroundColor()
    let fg = foregroundColor()
    let bd = boldColor()
    let bg2 = groupTableViewBackgroundColor()
    UIScrollView.appearance().indicatorStyle = scrollViewIndicatorStyle()
    UIView.appearance().tintColor = bd
    UINavigationBar.appearance().barTintColor = bg
    UITableView.appearance().separatorColor = UIColor(white: 0.5, alpha: 0.5)
    UITableView.appearance().backgroundColor = bg
    UITableView.appearance().sectionIndexBackgroundColor = bg
    SettingsTableView.appearance().backgroundColor = bg2
    UITableViewCell.appearance().backgroundColor = bg
    UITextField.appearance().textColor = fg
    UILabel.appearance().highlightedTextColor = selectedTextColor()
    UILabel.appearance().textColor = fg
    UIButton.appearance().setTitleColor(bd, forState: UIControlState.Normal)
    UIButton.appearance().setTitleColor(fg, forState: UIControlState.Selected)
    let cellSelectedView = UIView()
    cellSelectedView.backgroundColor = UIColor(betweenColor: bg!, andColor: bd!, percentage: 0.5)
    UITableViewCell.appearance().selectedBackgroundView = cellSelectedView
    let navbarAttr: Dictionary<String, UIColor> = [NSForegroundColorAttributeName: fg!]
    UINavigationBar.appearance().titleTextAttributes = navbarAttr
    BuildLogTextView.appearance().backgroundColor = bg
    BuildLogTextView.appearance().textColor = fg
    UIApplication.sharedApplication().setStatusBarStyle(statusBarStyle(), animated: true)
    resetViews()
    setAsCurrent()
  }

  public func resetViews() {
    let windows = UIApplication.sharedApplication().windows as! [UIWindow]
    for window in windows {
      let subviews = window.subviews as! [UIView]
      for v in subviews {
        v.removeFromSuperview()
        window.addSubview(v)
      }
    }
  }
}