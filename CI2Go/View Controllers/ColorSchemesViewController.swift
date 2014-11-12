//
//  ColorSchemesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class ColorSchemesViewController: UITableViewController {
  
  private var _sectionIndexes: [String]?
  private var _sections: [[String]] = []
  public var sectionIndexes: [String] {
    if !(_sectionIndexes?.count > 0) {
      buildSections()
    }
    return _sectionIndexes!
  }
  
  public var sections: [[String]] {
    if !(_sections.count > 0) {
      buildSections()
    }
    return _sections
  }
  
  private func buildSections() {
    _sectionIndexes = [String]()
    _sections = [[String]]()
    var section: [String]?
    for name in ColorScheme.names() {
      let fchar = name.substringToIndex(advance(name.startIndex, 1))
      if find(_sectionIndexes!, fchar) == nil {
        _sectionIndexes?.append(fchar)
        if section != nil {
          _sections.append(section!)
        }
        section = [String]()
      }
      section!.append(name)
    }
    _sections.append(section!)
  }
  
  public override func viewWillAppear(animated: Bool) {
    let name = ColorScheme().name
    let fchar = name.substringToIndex(advance(name.startIndex, 1))
    let section = find(sectionIndexes, fchar)
    if section != nil {
      let row = find(sections[section!], name)
      if row != nil {
        let indexPath = NSIndexPath(forRow: row!, inSection: section!)
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
      }
    }
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: "ColorScheme Screen")
    tracker.send(GAIDictionaryBuilder.createAppView().build())
  }
  
  public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectionIndexes.count
  }
  
  public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].count
  }
  
  public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as ColorSchemeTableViewCell
    cell.colorSchemeName = sections[indexPath.section][indexPath.row]
    return cell
  }
  
  public override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
    return sectionIndexes
  }
  
  public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionIndexes[section]
  }
  
  public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let item = sections[indexPath.section][indexPath.row]
    ColorScheme(name: item).apply()
    let tracker = GAI.sharedInstance().defaultTracker
    let dict = GAIDictionaryBuilder.createEventWithCategory("settings", action: "color-scheme-change", label: item, value: 1).build()
    tracker.send(dict)
    self.navigationController?.popToRootViewControllerAnimated(true)
  }
  
}
