//
//  ColorScheme.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

private var _names: [String] = []
private var _cache = [String: [String: [String: CGFloat]]]()

class ColorScheme {
    class var names: [String] {
        if _names.count == 0 {
            if let files = NSBundle.mainBundle().URLsForResourcesWithExtension("itermcolors", subdirectory: nil) {
                _names.appendContentsOf(files.map({ file in
                    return (file.lastPathComponent as NSString?)!.stringByDeletingPathExtension
                }))
            }
        }
        return _names
    }

    var name: String = ""
    lazy var dictionary: [String: [String: CGFloat]] = {
        let name = self.name
        if let dict = _cache[name] {
            return dict
        }
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: "itermcolors") {
            let dict = NSDictionary(contentsOfFile: path) as? [String: [String: CGFloat]]
            _cache[name] = dict
            return dict!
        }
        return [String: [String: CGFloat]]()
    }()

    init() {}

    convenience init?(_ name: String) {
        if !ColorScheme.names.contains(name) {
            return nil
        }
        self.init()
        self.name = name
    }

    func color(code code: Int) -> UIColor? {
        return color(key: NSString(format: "Ansi %d", code) as String)
    }

    func greenColor() -> UIColor? {
        return color(code: 2)
    }

    func redColor() -> UIColor? {
        return color(code: 1)
    }

    func blueColor() -> UIColor? {
        return color(code: 4)
    }

    func yellowColor() -> UIColor? {
        return color(code: 3)
    }

    func grayColor() -> UIColor? {
        return foregroundColor()?.colorWithAlphaComponent(0.4)
    }

    func foregroundColor() -> UIColor? {
        return color(key: "Foreground")
    }

    func selectedTextColor() -> UIColor? {
        return color(key: "Selected Text")
    }

    func backgroundColor() -> UIColor? {
        return color(key: "Background")
    }

    func selectionTextColor() -> UIColor? {
        return color(key: "Selection")
    }

    func boldColor() -> UIColor? {
        return color(key: "Bold")
    }

    func placeholderColor() -> UIColor? {
        return foregroundColor()?.colorWithAlphaComponent(0.2)
    }

    func groupTableViewBackgroundColor() -> UIColor? {
        if let c1 = backgroundColor(), c2 = boldColor() {
            return UIColor(betweenColor: c1, andColor: c2, percentage: CGFloat(0.05))
        }
        return nil
    }

    func color(key key: String) -> UIColor? {
        if let cmps = dictionary[key + " Color"]
            , r = cmps["Red Component"]
            , g = cmps["Green Component"]
            , b = cmps["Blue Component"] {
                return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        }
        return nil
    }

    func badgeColor(status status: String?) -> UIColor? {
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

    func actionColor(status status: Build.Status?) -> UIColor? {
        guard let status = status else { return UIColor.grayColor() }
        switch status {
        case .Success, .Fixed:
            return greenColor()
        case .Running:
            return yellowColor()
        case .Failed, .Timedout, .InfrastructureFail, .NoTests:
            return redColor()
        default:
            return UIColor.grayColor()
        }
    }

    func isLight() -> Bool {
        if let bg = backgroundColor() {
            var brightness: CGFloat = 0.0;
            bg.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
            return brightness > 0.5
        }
        return false
    }
    
    func setAsCurrent() {
        CI2GoUserDefaults.standardUserDefaults().colorSchemeName = name
    }

}