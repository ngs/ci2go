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

private var _shared: Pusher?
private let apiKey = "1cf6e0e755e419d2ac9a"
private let authURL = "https://circleci.com/auth/pusher?circle-token="

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
    @discardableResult func bind(_ event: PusherEvent, _ callback: (([[String: Any]]) -> Void)?) -> String {
        return bind(eventName: event.rawValue, callback: { data in
            callback?((data as? [[String: Any]]) ?? [])
        })
    }

    func unbind(_ event: PusherEvent, callbackId: String) {
        unbind(eventName: event.rawValue, callbackId: callbackId)
    }

    func bindBuildEvents(
        fetchBuild: @escaping ([[String: Any]]) -> Build?,
        completionHandler: @escaping (Build) -> Void) {
        let events: [PusherEvent] = [.newAction, .updateAction, .updateObservables, .fetchTestResults]
        events.forEach { event in
            self.bind(event, fetchBuild: fetchBuild, completionHandler: completionHandler)
        }
    }

    func bind(_ event: PusherEvent,
              fetchBuild: @escaping ([[String: Any]]) -> Build?,
              completionHandler: @escaping (Build) -> Void) {
        bind(event) { data in
            guard let build = fetchBuild(data) else {
                return
            }
            data.forEach { datum in
                guard
                    let log = datum["log"] as? [String: Any],
                    let step = datum["step"] as? Int,
                    let index = datum["index"] as? Int,
                    let name = log["name"] as? String,
                    let statusStr = log["status"] as? String,
                    let status = BuildAction.Status(rawValue: statusStr)
                    else { return }
                switch event {
                case .updateAction:
                    completionHandler(build.build(withNewActionStatus: status, in: index, step: step))
                case .newAction:
                    let newAction = BuildAction(name: name, index: index, step: step, status: status)
                    var buildStep = build.steps.first {$0.actions.first?.step == step }
                    if buildStep != nil {
                        let actions = buildStep!.actions + [newAction]
                        buildStep = BuildStep(name: name, actions: actions)
                    } else {
                        buildStep = BuildStep(name: name, actions: [newAction])
                    }
                    completionHandler(Build(build: build, newSteps: build.steps + [buildStep!]))
                default:
                    break
                }
            }
        }
    }
}
