//
//  ColorScheme+UIKit.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 6/13/15.
//  Copyright (c) 2015 LittleApps Inc. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

extension ColorScheme {

    func apply() {
        guard let bg = backgroundColor()
            , fg = foregroundColor()
            , bd = boldColor()
            , bg2 = groupTableViewBackgroundColor() else {
            return
        }
        UIApplication.sharedApplication().statusBarStyle = statusBarStyle()
        UIScrollView.appearance().indicatorStyle = scrollViewIndicatorStyle()
        UIView.appearance().tintColor = bd
        UINavigationBar.appearance().barTintColor = bg
        UITableView.appearance().separatorColor = UIColor(white: 0.5, alpha: 0.5)
        UIScrollView.appearance().backgroundColor = bg
        SettingsTableView.appearance().backgroundColor = bg
        UITableView.appearance().sectionIndexBackgroundColor = bg
        UIScrollView.appearanceWhenContainedInInstancesOfClasses([SettingsTableView.self]).backgroundColor = bg2
        UITableView.appearanceWhenContainedInInstancesOfClasses([SettingsTableView.self]).backgroundColor = bg2
        UITableView.appearance().backgroundColor = bg
        UITableViewCell.appearance().backgroundColor = bg
        UITextField.appearance().textColor = fg
        UILabel.appearanceWhenContainedInInstancesOfClasses([UITableViewCell.self]).textColor = fg
        UILabel.appearanceWhenContainedInInstancesOfClasses([UITableViewCell.self]).highlightedTextColor = selectedTextColor()
        UIButton.appearanceWhenContainedInInstancesOfClasses([UITableView.self]).setTitleColor(bd, forState: .Normal)
        UIButton.appearanceWhenContainedInInstancesOfClasses([UITableView.self]).setTitleColor(fg, forState: .Highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: bd], forState: .Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: fg], forState: .Highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: fg.colorWithAlphaComponent(0.4)], forState: .Disabled)
        let cellBackgroundView = UIView()
        cellBackgroundView.backgroundColor = bg
        UITableViewCell.appearance().backgroundView = cellBackgroundView
        let cellSelectedView = UIView()
        cellSelectedView.backgroundColor = UIColor(betweenColor: bg, andColor: bd, percentage: 0.5)
        UITableViewCell.appearance().selectedBackgroundView = cellSelectedView
        let navbarAttr: Dictionary<String, UIColor> = [NSForegroundColorAttributeName: fg]
        UINavigationBar.appearance().titleTextAttributes = navbarAttr
        UINavigationBar.appearance().barStyle = barStyle()
        BuildLogTextView.appearance().backgroundColor = bg
        BuildLogTextView.appearance().textColor = fg
        setAsCurrent()
        resetViews()
    }
    func statusBarStyle() -> UIStatusBarStyle {
        return isLight() ? .Default : .LightContent
    }

    func barStyle() -> UIBarStyle {
        return isLight() ? .Default : .Black
    }

    func scrollViewIndicatorStyle() -> UIScrollViewIndicatorStyle {
        return isLight() ? UIScrollViewIndicatorStyle.Black : UIScrollViewIndicatorStyle.White
    }

    func resetViews() {
        let windows = UIApplication.sharedApplication().windows
        for window in windows {
            let subviews = window.subviews
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
}