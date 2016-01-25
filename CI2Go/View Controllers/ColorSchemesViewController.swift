//
//  ColorSchemesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import Crashlytics

class ColorSchemesViewController: UITableViewController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return ColorScheme().statusBarStyle()
    }

    lazy var sectionIndexes: [String] = {
        return ColorScheme.names.map({ $0.firstString }).unique
    }()

    lazy var sections: [[String]] = {
        return self.sectionIndexes.map { section in
            ColorScheme.names.filter{ $0.firstString == section }
        }
    }()

    override func viewWillAppear(animated: Bool) {
        let name = ColorScheme().name
        guard let fchar = name.characters.first else {
            return
        }
        let str = String(fchar)
        let section = sectionIndexes.indexOf(str)
        if section != nil {
            let row = sections[section!].indexOf(name)
            if row != nil {
                let indexPath = NSIndexPath(forRow: row!, inSection: section!)
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "ColorScheme Screen")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
        Answers.logContentViewWithName("Color Scheme", contentType: nil, contentId: nil, customAttributes: [:])
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionIndexes.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as! ColorSchemeTableViewCell
        cell.colorSchemeName = sections[indexPath.section][indexPath.row]
        return cell
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return sectionIndexes
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionIndexes[section]
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = sections[indexPath.section][indexPath.row]
        guard let colorScheme = ColorScheme(item) else { return }
        colorScheme.apply()
        let tracker = GAI.sharedInstance().defaultTracker
        let dict = GAIDictionaryBuilder.createEventWithCategory("settings", action: "color-scheme-change", label: item, value: 1).build() as [NSObject : AnyObject]
        tracker.send(dict)
        Answers.logCustomEventWithName("Color Scheme Change", customAttributes: ["name": colorScheme.name])
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
