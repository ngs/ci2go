//
//  ColorScheme.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

private var _names: [String]? = nil

public class ColorScheme: NSObject {
  public class func names() -> [String] {
    if _names == nil {
      _names = [String]()
      let files = NSBundle.mainBundle().URLsForResourcesWithExtension("itermcolors", subdirectory: nil) as [NSURL]?
      if files != nil {
        for file in files! {
          _names!.append(file.lastPathComponent.stringByDeletingPathExtension)
        }
      }
    }
    return _names!
  }
  
  private var _name: String
  public var name: String { return _name }
  private var _dictionary: Dictionary<String, Dictionary<String, NSNumber>>?
  public var dictionary: Dictionary<String, Dictionary<String, NSNumber>> {
    if nil == _dictionary {
      let path = NSBundle.mainBundle().pathForResource(name, ofType: "itermcolors")
      if nil != path {
        _dictionary = NSDictionary(contentsOfFile: path!) as Dictionary<String, Dictionary<String, NSNumber>>?
      }
    }
    if nil == _dictionary {
      _dictionary = Dictionary<String, Dictionary<String, NSNumber>>()
    }
    return _dictionary!
  }
  
  override convenience init() {
    self.init(name: CI2GoUserDefaults.standardUserDefaults().colorSchemeName!)
  }
  
  public init(name: String) {
    _name = name
  }
  
  public func color(#code: Int) -> UIColor? {
    return color(key: NSString(format: "Ansi %d", code))
  }
  
  public func foregroundColor() -> UIColor? {
    return color(key: "Foreground")
  }
  
  public func backgroundColor() -> UIColor? {
    return color(key: "Background")
  }
  
  public func selectedTextColor() -> UIColor? {
    return color(key: "Selected Text")
  }
  
  public func selectionTextColor() -> UIColor? {
    return color(key: "Selection")
  }
  
  public func boldColor() -> UIColor? {
    return color(key: "Bold")
  }
  
  public func placeholderColor() -> UIColor? {
    return foregroundColor()?.colorWithAlphaComponent(0.2)
  }
  
  public func groupTableViewBackgroundColor() -> UIColor? {
    return UIColor(betweenColor: backgroundColor(), andColor: boldColor(), percentage: 0.05)
  }
  
  public func color(#key: String) -> UIColor? {
    if let cmps = dictionary[key + " Color"] {
      let red = CGFloat(cmps["Red Component"]!.floatValue)
      let green = CGFloat(cmps["Green Component"]!.floatValue)
      let blue = CGFloat(cmps["Blue Component"]!.floatValue)
      return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    return nil
  }
  
  public func isLight() -> Bool {
    if let bg = backgroundColor() {
      var brightness: CGFloat = 0.0;
      bg.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
      return brightness > 0.5
    }
    return false
  }
  
  public func statusBarStyle() -> UIStatusBarStyle {
    return isLight() ? UIStatusBarStyle.Default : UIStatusBarStyle.LightContent
  }

  public func scrollViewIndicatorStyle() -> UIScrollViewIndicatorStyle {
    return isLight() ? UIScrollViewIndicatorStyle.Black : UIScrollViewIndicatorStyle.White
  }

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
    let windows = UIApplication.sharedApplication().windows as [UIWindow]
    for window in windows {
      let subviews = window.subviews as [UIView]
      for v in subviews {
        v.removeFromSuperview()
        window.addSubview(v)
      }
    }
  }
  
  public func setAsCurrent() {
    CI2GoUserDefaults.standardUserDefaults().colorSchemeName = name
  }
  
}