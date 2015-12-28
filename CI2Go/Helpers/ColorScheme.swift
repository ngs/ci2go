//
//  ColorScheme.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

private var _names: [String]? = nil
private var _cache = Dictionary<String, Dictionary<String, Dictionary<String, NSNumber>>>()

public class ColorScheme: NSObject {
    public class func names() -> [String] {
        if _names == nil {
            _names = [String]()
            let files = NSBundle.mainBundle().URLsForResourcesWithExtension("itermcolors", subdirectory: nil)
            if files != nil {
                for file in files! {
                    _names!.append((file.lastPathComponent! as NSString).stringByDeletingPathExtension)
                }
            }
            _names?.sortInPlace({ (a: String, b: String) -> Bool in
                return a < b
            })
        }
        return _names!
    }

    private var _name: String
    public var name: String { return _name }
    private var _dictionary: Dictionary<String, Dictionary<String, NSNumber>>?
    public var dictionary: Dictionary<String, Dictionary<String, NSNumber>> {
        if nil == _dictionary {
            _dictionary = _cache[name]
        }
        if nil == _dictionary {
            let path = NSBundle.mainBundle().pathForResource(name, ofType: "itermcolors")
            if nil != path {
                _dictionary = NSDictionary(contentsOfFile: path!) as! Dictionary<String, Dictionary<String, NSNumber>>?
                _cache[name] = _dictionary
            }
        }
        if nil == _dictionary {
            _dictionary = Dictionary<String, Dictionary<String, NSNumber>>()
        }
        return _dictionary!
    }

    override convenience init() {
        self.init(name: CI2GoUserDefaults.standardUserDefaults().colorSchemeName! as String)
    }

    public init(name: String) {
        _name = name
    }

    public func color(code code: Int) -> UIColor? {
        return color(key: NSString(format: "Ansi %d", code) as String)
    }

    public func greenColor() -> UIColor? {
        return color(code: 2)
    }

    public func redColor() -> UIColor? {
        return color(code: 1)
    }

    public func blueColor() -> UIColor? {
        return color(code: 4)
    }

    public func yelloColor() -> UIColor? {
        return color(code: 3)
    }

    public func grayColor() -> UIColor? {
        return foregroundColor()?.colorWithAlphaComponent(0.4)
    }

    public func foregroundColor() -> UIColor? {
        return color(key: "Foreground")
    }

    public func selectedTextColor() -> UIColor? {
        return color(key: "Selected Text")
    }

    public func backgroundColor() -> UIColor? {
        return color(key: "Background")
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
        if let c1 = backgroundColor(), c2 = boldColor() {
            return UIColor(betweenColor: c1, andColor: c2, percentage: CGFloat(0.05))
        }
        return nil
    }

    public func color(key key: String) -> UIColor? {
        if let cmps = dictionary[key + " Color"] {
            let red = CGFloat(cmps["Red Component"]!.floatValue)
            let green = CGFloat(cmps["Green Component"]!.floatValue)
            let blue = CGFloat(cmps["Blue Component"]!.floatValue)
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        return nil
    }

    public func badgeColor(status status: String?) -> UIColor? {
        if status != nil {
            switch status! {
            case "fixed", "success":
                return greenColor()
            case "running":
                return blueColor()
            case "failed", "timedout":
                return redColor()
            default:
                return UIColor.grayColor()
            }
        }
        return UIColor.grayColor()
    }

    public func actionColor(status status: String?) -> UIColor? {
        if status != nil {
            switch status! {
            case "success":
                return greenColor()
            case "running":
                return yelloColor()
            case "failed", "timedout":
                return redColor()
            default:
                return UIColor.grayColor()
            }
        }
        return UIColor.grayColor()
    }

    public func isLight() -> Bool {
        if let bg = backgroundColor() {
            var brightness: CGFloat = 0.0;
            bg.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
            return brightness > 0.5
        }
        return false
    }

    public func setAsCurrent() {
        CI2GoUserDefaults.standardUserDefaults().colorSchemeName = name
    }
    
}