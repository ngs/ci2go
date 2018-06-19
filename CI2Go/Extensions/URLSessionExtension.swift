//
//  URLSessionExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import KeychainAccess

extension URLSession {
    func dataTask<T: Decodable>(
        endpoint: Endpoint<T>,
        token: String? = nil,
        completionHandler: ((T?, Data?, URLResponse?, Error?) -> Void)? = nil) -> URLSessionDataTask {
        NetworkActivityManager.start()
        return dataTask(
            with: endpoint.urlRequest(with: token ?? Keychain.shared.token),
            completionHandler: { (data, res, err) in
                guard let completionHandler = completionHandler else { return }
                guard let data = data else {
                    completionHandler(nil, nil, res, err)
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .custom({ d in
                        let container = try d.singleValueContainer()
                        let dateStr = try container.decode(String.self)
                        let formatter = DateFormatter()
                        formatter.calendar = Calendar(identifier: .iso8601)
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        // 2018-06-19T06:29:50.030Z
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        if let date = formatter.date(from: dateStr) {
                            return date
                        }
                        // 2018-06-19T15:29:08+09:00
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
                        if let date = formatter.date(from: dateStr) {
                            return date
                        }
                        throw DateError.invalidDate
                    })
                    let decoded = try decoder.decode(T.self, from: data)
                    completionHandler(decoded, data, res, nil)
                } catch {
                    completionHandler(nil, data, res, error)
                }
                NetworkActivityManager.stop()
        })
    }
}
