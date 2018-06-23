//
//  URLSessionExtension+Keychain.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import KeychainAccess

extension URLSession {
    func dataTask<T: Decodable>(
        endpoint: Endpoint<T>,
        completionHandler: ((T?, Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionDataTask {
        return dataTask(endpoint: endpoint, token: Keychain.shared.token, completionHandler: completionHandler)
    }
}
