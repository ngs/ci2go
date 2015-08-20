//
//  NSManagedObject+entityName.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
  // https://gist.github.com/akisute/dc603e4776815c438ffb
  public class var entityName:String {
    get {
      return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
  }

}
