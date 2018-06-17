//
//  ColorScheme+UI.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import SafariServices

extension ColorScheme {
    func apply() {
        let app = UIApplication.shared
        app.statusBarStyle = statusBarStyle
        app.windows.forEach { $0.tintColor = bold }

        let navigationBar = UINavigationBar.appearance() as UINavigationBar
        navigationBar.barTintColor = background
        navigationBar.barStyle = barStyle
        navigationBar.titleTextAttributes = [
            .foregroundColor: foreground
        ]

        let scrollView = UIScrollView.appearance() as UIScrollView
        scrollView.indicatorStyle = scrollViewIndicatorStyle
        scrollView.backgroundColor = background

        let tableView = UITableView.appearance() as UITableView
        tableView.separatorColor = tableViewSeperator
        tableView.sectionIndexBackgroundColor = background
        tableView.backgroundColor = background

        let tableViewCell = UITableViewCell.appearance() as UITableViewCell

        let cellBackgroundView = UIView()
        cellBackgroundView.backgroundColor = background

        let cellSelectedBackgroundView = UIView()
        cellSelectedBackgroundView.backgroundColor = tableViewCellSelectedBackground

        tableViewCell.backgroundColor = background
        tableViewCell.backgroundView = cellBackgroundView
        tableViewCell.selectedBackgroundView = cellSelectedBackgroundView

        let textField = UITextField.appearance() as UITextField
        textField.textColor = foreground

        let cellLabel = UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
        cellLabel.textColor = foreground
        cellLabel.highlightedTextColor = selectedText

        let settingsTableView = SettingsTableView.appearance()
        settingsTableView.backgroundColor = background

        UIScrollView.appearance(whenContainedInInstancesOf: [SettingsTableView.self]).backgroundColor = groupTableViewBackground

        UITableView.appearance(whenContainedInInstancesOf: [SettingsTableView.self]).backgroundColor = groupTableViewBackground

        let tableButton = UIButton.appearance(whenContainedInInstancesOf: [UITableView.self]) as UIButton

        tableButton.setTitleColor(bold, for: .normal)
        tableButton.setTitleColor(foreground, for: .highlighted)

        let buildLogTextView = BuildLogTextView.appearance()
        buildLogTextView.backgroundColor = background
        buildLogTextView.textColor = foreground

        // TODO: customize UIAlertController.
        // TODO: SFSafariViewController preferredControlTintColor

        setAsCurrent()
        resetViews()
    }

    var statusBarStyle: UIStatusBarStyle {
        return isLight ? .default : .lightContent
    }

    var barStyle: UIBarStyle {
        return isLight ? .default : .black
    }

    var scrollViewIndicatorStyle: UIScrollViewIndicatorStyle {
        return isLight ? .black : .white
    }

    func resetViews() {
        let windows = UIApplication.shared.windows
        for window in windows {
            let subviews = window.subviews
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
}
