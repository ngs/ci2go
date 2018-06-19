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
        if let value = value {
            colorScheme = ColorScheme(value)
        } else {
            colorScheme = nil
        }
      }
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    nameLabel.text = colorScheme?.name
    yellowColorView.backgroundColor = colorScheme?.yellow
    blueColorView.backgroundColor = colorScheme?.blue
    redColorView.backgroundColor = colorScheme?.red
    greenColorView.backgroundColor = colorScheme?.green
    backgroundColor = colorScheme?.background
    nameLabel.textColor = colorScheme?.foreground
  }

}
