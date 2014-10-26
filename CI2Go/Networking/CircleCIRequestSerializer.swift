//
//  CircleCIRequestSerializer.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation

public class CircleCIRequestSerializer: AFHTTPRequestSerializer {
  
  public var apiToken: String?
  
  override public func requestWithMethod(method: String!,
    URLString: String!,
    parameters: AnyObject!, error: NSErrorPointer) -> NSMutableURLRequest! {
      setValue("application/json", forHTTPHeaderField: "Accept")
      var URLWithToken = URLString
      if apiToken != nil {
        URLWithToken = URLString! + "?circle-token=" + apiToken!
      }
      return super.requestWithMethod(method, URLString: URLWithToken, parameters: parameters, error: error)
  }
  
}