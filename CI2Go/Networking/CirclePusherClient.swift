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
import Crashlytics

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
            "authEndpoint": kCI2GoPusherAuthorizationURL + (circleToken ?? "")])
        p.connect()
        return p
    }
    deinit {
        self.pusherClient.disconnect()
    }
    func subscribeBuild(build: Build) -> Observable<Void> {
        return Observable.create { observer in
            if let n = build.pusherAllChannelName {
                let channel = self.pusherClient.subscribe(n)
                channel.bind("updateObservables", callback: { _ in observer.onNext() })
                channel.bind("maybeAddMessages", callback: { _ in observer.onNext() })
                channel.bind("fetchTestResults", callback: { _ in observer.onNext() })
            }
            build.pusherContainerChannelNames.forEach { n in
                let channel = self.pusherClient.subscribe(n)
                channel.bind("newAction", callback: { _ in observer.onNext() })
                channel.bind("updateAction", callback: { _ in observer.onNext() })
            }
            return AnonymousDisposable {
                build.pusherChannelNames.forEach {n in
                    self.pusherClient.unsubscribe(n)
                }

            }
        }
    }
    func subscribeBuildLog(buildAction: BuildAction) -> Observable<Void> {
        guard let channelName = buildAction.pusherChannelName else { return Observable.never() }
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
                    Crashlytics.sharedInstance().setUserEmail(user.email)
                    Crashlytics.sharedInstance().setUserIdentifier(user.login)
                    Crashlytics.sharedInstance().setUserName(user.name)
                    Answers.logLoginWithMethod("API Token", success: NSNumber(bool: true),
                        customAttributes: ["login": user.login, "name": user.name])
                    channel = self.pusherClient.subscribe("private-\(user.login)")
                    channel?.bind("call", callback: { res in
                        if let res = res as? [String: AnyObject]
                            , fn = res["fn"] as? String where fn == "refreshBuildState" {
                                observer.onNext()
                        }
                    })
                },
                onError: { e in
                    Answers.logLoginWithMethod("API Token", success: NSNumber(bool: false),
                        customAttributes: ["error": "\(e)"])
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