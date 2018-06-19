//
//  PusherExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import PusherSwift
import KeychainAccess

fileprivate var _shared: Pusher?
fileprivate let apiKey = "1cf6e0e755e419d2ac9a"
fileprivate let authURL = "https://circleci.com/auth/pusher?circle-token="

class PusherAuthRequestBuilder: AuthRequestBuilderProtocol {
    let token: String

    init(_ token: String) {
        self.token = token
    }

    func requestFor(socketID: String, channelName: String) -> URLRequest? {
        var request = URLRequest(url: URL(string: authURL + token)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)".data(using: .utf8)
        return request
    }
}

extension Pusher {
    static var shared: Pusher? {
        if let shared = _shared {
            return shared
        }
        guard let token = Keychain.shared.token else {
            return nil
        }
        let options = PusherClientOptions(authMethod: .init(authRequestBuilder: PusherAuthRequestBuilder(token)))
        let shared = Pusher(key: apiKey, options: options)
        _shared = shared
        return shared
    }

    static func logout() {
        guard let shared = _shared else { return }
        shared.unsubscribeAll()
        _shared = nil
    }
}

extension PusherChannel {
    @discardableResult func bind(_ event: PusherEvent, _ callback: (([String: Any]) -> Void)?) -> String {
        return bind(eventName: event.rawValue, callback: { data in
            callback?((data as? [String: Any]) ?? [:])
        })
    }
}
