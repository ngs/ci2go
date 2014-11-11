//
//  ColorSchemeTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/11/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

class ColorSchemeTableViewCell: UITableViewCell {


  @IBOutlet weak var yellowColorView: UIView!
  @IBOutlet weak var blueColorView: UIView!
  @IBOutlet weak var greenColorView: UIView!
  @IBOutlet weak var redColorView: UIView!
  @IBOutlet weak var nameLabel: UILabel!

  var colorScheme: ColorScheme? {
    didSet {
      setNeedsLayout()
    }
  }

  var colorSchemeName: String? {
    get {
      return colorScheme?.name
    }
    set(value) {
      if colorScheme?.name != value {
        if value == nil {
          colorScheme = nil
        } else {
          colorScheme = ColorScheme(name: value!)
        }
      }
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    nameLabel.text = colorScheme?.name
    yellowColorView.backgroundColor = colorScheme?.yelloColor()
    blueColorView.backgroundColor = colorScheme?.blueColor()
    redColorView.backgroundColor = colorScheme?.redColor()
    greenColorView.backgroundColor = colorScheme?.greenColor()
    backgroundColor = colorScheme?.backgroundColor()
    nameLabel.textColor = colorScheme?.foregroundColor()
  }

}
