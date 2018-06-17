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
        completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: endpoint.urlRequest(with: token), completionHandler: { (data, res, err) in
            guard let data = data else {
                completionHandler(nil, res, err)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(T.self, from: data)
                completionHandler(decoded, res, nil)
            } catch {
                completionHandler(nil, res, error)
            }
        })
    }
}
