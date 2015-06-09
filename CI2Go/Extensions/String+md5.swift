//
//  String+md5.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/11/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation

// http://stackoverflow.com/a/24408724

extension String  {
  var md5: String! {
    let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
    let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
    CC_MD5(str!, strLen, result)
    var hash = NSMutableString()
    for i in 0..<digestLen {
      hash.appendFormat("%02x", result[i])
    }
    result.destroy()
    return String(format: hash as String)
  }
}
