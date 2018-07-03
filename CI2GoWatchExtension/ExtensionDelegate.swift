//
//  ExtensionDelegate.swift
//  CI2GoWatch Extension
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import WatchKit
import KeychainAccess
import FileKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionDownloadDelegate {
    let backgroundDownloadTaskIdentifier = "ci2go-background-download"

    var pendingBackgroundTasks: [WKRefreshBackgroundTask] = []

    func applicationDidEnterBackground() {
        scheduleBackgroundRefresh()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                download()
                pendingBackgroundTasks.append(backgroundTask)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                snapshotTask.setTaskCompleted(
                    restoredDefaultState: true,
                    estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                scheduleSnapshotRefresh()
                connectivityTask.setTaskCompletedWithSnapshot(true)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                scheduleSnapshotRefresh()
                urlSessionTask.setTaskCompletedWithSnapshot(true)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func scheduleBackgroundRefresh() {
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate:
        Date(timeIntervalSinceNow: 600), userInfo: nil) { err in
            if let err = err {
                print(err)
            }
        }
    }

    func scheduleSnapshotRefresh() {
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate:
        Date(timeIntervalSinceNow: 60), userInfo: nil) { err in
            if let err = err {
                print(err)
            }
        }
    }

    func download() {
        let defaults = UserDefaults.shared
        let endpoint = Endpoint<[Build]>.builds(object: defaults.branch ?? defaults.project, offset: 0, limit: 20)
        let req = endpoint.urlRequest(with: Keychain.shared.token)
        let config = URLSessionConfiguration.background(withIdentifier: backgroundDownloadTaskIdentifier)
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: req)
        task.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let cacheFile = [Build].cacheFile
        try? cacheFile.delete()
        try? Path(location.path).moveFile(to: cacheFile.path)
        pendingBackgroundTasks.forEach { $0.setTaskCompletedWithSnapshot(true) }
        pendingBackgroundTasks.removeAll()
        let srv = CLKComplicationServer.sharedInstance()
        srv.activeComplications?.forEach {
            srv.reloadTimeline(for: $0)
        }
        scheduleSnapshotRefresh()
        scheduleBackgroundRefresh()
    }
}
