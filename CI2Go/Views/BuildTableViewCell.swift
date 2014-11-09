//
//  BuildTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/10/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit

public class BuildTableViewCell: UITableViewCell {

  private var _build: Build? = nil
  public var build: Build? {

    set(value) {
      _build = value
      textLabel.text = value?.number.description
    }
    get {
      return _build
    }
  }
}
