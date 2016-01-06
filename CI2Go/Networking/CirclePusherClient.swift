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

class CirclePusherClient {
    let appendActionSubject = PublishSubject<String>()
    let updateActionSubject = PublishSubject<String>()
    let newActionSubject = PublishSubject<String>()
    let refreshBuildStateSubject = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    lazy var pusherClient: Pusher = {
        let p = Pusher(key: kCI2GoPusherAPIKey, options: [
            "attemptToReturnJSONObject": true,
            "autoReconnect": true,
            "authEndpoint": kCI2GoPusherAuthorizationURL,
            "authRequestCustomizer": { (req: NSMutableURLRequest) -> NSMutableURLRequest in
                req.HTTPBody = req.URL?.query?.componentsSeparatedByString("?").last?.dataUsingEncoding(NSUTF8StringEncoding)
                if let token = CI2GoUserDefaults.standardUserDefaults().circleCIAPIToken
                    , URL = NSURL(string: kCI2GoPusherAuthorizationURL + token) { req.URL = URL }
                return req
            }])
        p.connect()
        return p
    }()
    deinit {
        self.pusherClient.disconnect()
    }
    init() {
    }
    init(build: Build) {
        //        if let channelName = build.pusherChannelName {
        //            pusherChannel = pusherClient.subscribe(channelName)
        //        }
    }
    func subscribeRefresh() -> Observable<Void> {
        return Observable.create({ observer in
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
                    self.pusherClient.bind { res in
                        print(res)
                    }
                    channel?.bind("pusher:subscription_succeeded", callback: { res in
                        print(res)
                    })
                    channel?.bind("pusher:subscription_error", callback: { res in
                        print(res)
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
        })
    }
}