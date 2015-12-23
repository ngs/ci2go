//
//  CircleCIRequestSerializer.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import AFNetworking

public class CircleCIRequestSerializer: AFHTTPRequestSerializer {
  
  public var apiToken: String?

  public override func requestWithMethod(method: String!,
    URLString: String!,
    parameters: AnyObject!, error: ()) throws -> NSMutableURLRequest {
      setValue("application/json", forHTTPHeaderField: "Accept")
      var URLWithToken = URLString
      if apiToken != nil {
        URLWithToken = URLString! + "?circle-token=" + apiToken!
      }
      return try super.requestWithMethod(method, URLString: URLWithToken, parameters: parameters, error: error)
  }
  
}