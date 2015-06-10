//
//  CircleCIAPISessionManager.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/28/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation

public class CircleCIAPISessionManager: AFHTTPRequestOperationManager {
  
  override init(baseURL url: NSURL!) {
    super.init(baseURL: url)
    self.requestSerializer = CircleCIRequestSerializer() as AFHTTPRequestSerializer
    self.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments)
    self.apiToken = nil
  }
  
  public convenience init(apiToken: String?) {
    self.init()
    self.apiToken = apiToken
  }
  
  convenience init() {
    self.init(baseURL: kCI2GoCircleCIAPIBaseURL)
    self.apiToken = CI2GoUserDefaults.standardUserDefaults().circleCIAPIToken as String?
  }
  
  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public var apiToken: String? {
    set(value) {
      (self.requestSerializer as! CircleCIRequestSerializer).apiToken = value
    }
    get {
      return (self.requestSerializer as! CircleCIRequestSerializer).apiToken
    }
  }
  
}