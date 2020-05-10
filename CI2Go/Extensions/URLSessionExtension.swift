//
//  URLSessionExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension URLSession {
    func dataTask<T: Decodable>(
        endpoint: Endpoint<T>,
        token: String?,
        completionHandler: ((T?, Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionDataTask {
        return dataTask(
            with: endpoint.urlRequest(with: token),
            completionHandler: { (data, res, err) in
                guard let completionHandler = completionHandler else { return }
                guard let data = data else {
                    completionHandler(nil, nil, res, err)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .custom({ try DateDecoder.decode($0) })
                    let decoded = try decoder.decode(T.self, from: data)
                    completionHandler(decoded, data, res, nil)
                } catch {
                    completionHandler(nil, data, res, error)
                }
        })
    }
}
