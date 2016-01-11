//
//  WatchMessageHandler.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/7/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import WatchConnectivity
import RxSwift
import RealmSwift
import ObjectMapper

class WatchMessageHandler: NSObject, WCSessionDelegate {
    let disposeBag = DisposeBag()

    lazy var tracker: GAITracker = {
        return GAI.sharedInstance()
            .trackerWithName("AppleWatch", trackingId: kCI2GoGATrackingId)
    }()

    func activate() -> Bool {
        guard WCSession.isSupported() else { return false }
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        return true
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let rawFn = message[kCI2GoWatchConnectivityFunctionKey] as? String, fn = CI2GoWatchConnectivityFunction(rawValue: rawFn) {
            switch fn {
            case .AppLaunch:
                handleAppLaunch(replyHandler)
                return
            case .RetryBuild:
                handleRetryBuild(message, replyHandler)
                break
            case .RequestBuilds:
                handleRequestBuilds(replyHandler)
                break
            case .TrackScreen:
                handleTrackScreen(message)
                break
            case .TrackEvent:
                handleTrackEvent(message)
                break
            }
        }
    }

    func handleAppLaunch(replyHandler: ([String : AnyObject]) -> Void) {
        let def = CI2GoUserDefaults.standardUserDefaults()
        let apiToken = def.circleCIAPIToken ?? ""
        let colorSchemeName = def.colorSchemeName ?? ColorScheme.defaultSchemeName
        replyHandler([
            kCI2GoWatchConnectivityApiTokenKey: apiToken,
            kCI2GoWatchConnectivityColorSchemeNameKey: colorSchemeName
            ])
    }

    func handleRetryBuild(message: [String : AnyObject], _ replyHandler: ([String : AnyObject]) -> Void) {
        guard let buildId = message[kCI2GoWatchConnectivityBuildIdKey] as? String else { return }
        let realm = try! Realm()
        let build = realm.objectForPrimaryKey(Build.self, key: buildId)
        build?.post("retry").subscribeNext { build in
            replyHandler([kCI2GoWatchConnectivityBuildIdKey: build.id])
            }.addDisposableTo(disposeBag)
    }

    func handleRequestBuilds(replyHandler: ([String : AnyObject]) -> Void) {
        Build.getRecent(0, limit: 20).subscribeNext { builds in
            let json = Mapper<BuildCompact>().toJSONArray(builds.map{ BuildCompact(build: $0) })
            replyHandler([kCI2GoWatchConnectivityBuildsKey: json])
            }.addDisposableTo(disposeBag)
    }

    func handleTrackScreen(message: [String : AnyObject]) {
        guard let screenName = message[kCI2GoWatchConnectivityScreenNameKey] as? String else { return }
        tracker.set(kGAIScreenName, value: screenName)
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }

    func handleTrackEvent(message: [String : AnyObject]) {
        guard let category = message[kCI2GoWatchConnectivityEventCategoryKey] as? String
            , action = message[kCI2GoWatchConnectivityEventActionKey] as? String
            , label = message[kCI2GoWatchConnectivityEventLabelKey] as? String
            , value = message[kCI2GoWatchConnectivityEventValueKey] as? Int else { return }
        let dict = GAIDictionaryBuilder
            .createEventWithCategory(category, action: action, label: label, value: value).build() as [NSObject : AnyObject]
        tracker.send(dict)
    }
    
}