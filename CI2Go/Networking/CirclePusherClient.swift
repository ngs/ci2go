//
//  CirclePusherClient.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/6/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import PusherSwift
import RxSwift
import RealmSwift
import RealmResultsController
import ObjectMapper

class CirclePusherClient {
    let disposeBag = DisposeBag()
    var circleToken: String? = nil
    private var _pusherClient: Pusher?
    var pusherClient: Pusher {
        let token = CI2GoUserDefaults.standardUserDefaults().circleCIAPIToken
        if let c = _pusherClient where circleToken == token {
            return c
        }
        circleToken = token
        let p = Pusher(key: kCI2GoPusherAPIKey, options: [
            "attemptToReturnJSONObject": true,
            "autoReconnect": true,
            "authEndpoint": kCI2GoPusherAuthorizationURL,
            "authRequestCustomizer": { (req: NSMutableURLRequest) -> NSMutableURLRequest in
                req.HTTPBody = req.URL?.query?.componentsSeparatedByString("?").last?.dataUsingEncoding(NSUTF8StringEncoding)
                if let token = token, URL = NSURL(string: kCI2GoPusherAuthorizationURL + token) { req.URL = URL }
                return req
            }])
        p.connect()
        return p
    }
    deinit {
        self.pusherClient.disconnect()
    }
    func subscribeBuild(build: Build) -> Observable<Void> {
        guard let channelName = build.pusherChannelName else { return Observable.never() }
        return Observable.create { observer in
            let channel = self.pusherClient.subscribe(channelName)
            channel.bind("newAction", callback: { _ in observer.onNext() })
            channel.bind("updateAction", callback: { _ in observer.onNext() })
            return AnonymousDisposable {
                self.pusherClient.unsubscribe(channelName)
            }
        }
    }
    func subscribeBuildLog(buildAction: BuildAction) -> Observable<Void> {
        let build = buildAction.buildStep?.build
        guard let channelName = build?.pusherChannelName else { return Observable.never() }
        return Observable.create { observer in
            let channel = self.pusherClient.subscribe(channelName)
            channel.bind("appendAction", callback: { res in
                guard let res = res as? [[String: AnyObject]] else { return }
                    res.forEach { json in
                    guard let stepNumber = json["step"] as? Int
                        , nodeIndex = json["index"] as? Int
                        , out = json["out"] as? [String: AnyObject]
                        , message = out["message"] as? String
                        where buildAction.stepNumber == stepNumber && buildAction.nodeIndex == nodeIndex
                        else { return }
                    buildAction.appendLog(message)
                }
            })
            return AnonymousDisposable {
                self.pusherClient.unsubscribe(channelName)
            }
        }
    }
    func subscribeRefresh() -> Observable<Void> {
        return Observable.create { observer in
            var disposables = [Disposable]()
            var channel: PusherChannel?
            disposables.append(User.me().subscribe(
                onNext: { user in
                    channel = self.pusherClient.subscribe("private-\(user.login)")
                    channel?.bind("call", callback: { res in
                        if let res = res as? [String: AnyObject]
                            , fn = res["fn"] as? String where fn == "refreshBuildState" {
                                observer.onNext()
                        }
                    })
                },
                onError: { e in
                    observer.onError(e)
                }
                ))
            return AnonymousDisposable {
                disposables.forEach { $0.dispose() }
                if let channelName = channel?.name {
                    self.pusherClient.unsubscribe(channelName)
                }
            }
        }
    }
}