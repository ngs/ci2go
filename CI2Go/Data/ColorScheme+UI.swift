//
//  ColorScheme+UI.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import SafariServices
import QuickLook
import WatchConnectivity

extension ColorScheme {
    func apply() { // swiftlint:disable:this function_body_length
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

        let tableView = UITableView.appearance() as UITableView
        tableView.separatorColor = tableViewSeperator
        tableView.sectionIndexBackgroundColor = background
        tableView.backgroundColor = background

        let tableViewCell = UITableViewCell.appearance() as UITableViewCell
        tableViewCell.backgroundColor = background

        let textField = UITextField.appearance() as UITextField
        textField.textColor = foreground

        let cellImageView = UIImageView.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
        cellImageView.tintColor = foreground

        let cellLabel = UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
        cellLabel.textColor = foreground
        cellLabel.highlightedTextColor = selectedText

        let settingsTableView = SettingsTableView.appearance()
        settingsTableView.backgroundColor = background

        UITableView.appearance(
            whenContainedInInstancesOf: [SettingsTableView.self])
            .backgroundColor = groupTableViewBackground

        let tableButton = UIButton.appearance(whenContainedInInstancesOf: [UITableView.self]) as UIButton

        tableButton.setTitleColor(bold, for: .normal)
        tableButton.setTitleColor(foreground, for: .highlighted)

        let textView = CustomTextView.appearance()
        textView.backgroundColor = background
        textView.textColor = foreground

        let activityIndicatorView = UIActivityIndicatorView.appearance() as UIActivityIndicatorView
        activityIndicatorView.activityIndicatorViewStyle = activityIndicatorViewStyle

        let alertView = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]) as UIView
        alertView.tintColor = alertViewTint

        let buildActionSectionHeaderView = SectionHeaderView.appearance()
        buildActionSectionHeaderView.backgroundColor = background.withAlphaComponent(0.7)

        let buildActionSectionHeaderLabel = UILabel.appearance(whenContainedInInstancesOf: [SectionHeaderView.self])
        buildActionSectionHeaderLabel.textColor = foreground
        buildActionSectionHeaderLabel.backgroundColor = .clear

        UIRefreshControl.appearance().tintColor = foreground

        UIImageView.appearance(whenContainedInInstancesOf: [SettingsFooterView.self]).tintColor = foreground
        UILabel.appearance(whenContainedInInstancesOf: [SettingsFooterView.self]).textColor = foreground

        setAsCurrent()
        WCSession.default.transferColorScheme(colorScheme: self)
        resetViews()
    }

    var alertViewTint: UIColor {
        return isLight ? foreground : background
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

    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        return isLight ? .gray : .white
    }

    func resetViews() {
        let windows = UIApplication.shared.windows
        for window in windows {
            let subviews = window.subviews
            for view in subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
    }
}
