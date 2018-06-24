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
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                download()
                pendingBackgroundTasks.append(backgroundTask)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                scheduleSnapshotRefresh()
                connectivityTask.setTaskCompletedWithSnapshot(true)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                scheduleSnapshotRefresh()
                urlSessionTask.setTaskCompletedWithSnapshot(true)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func scheduleBackgroundRefresh() {
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: 600), userInfo: nil) { err in
            if let err = err {
                print(err)
            }
        }
    }

    func scheduleSnapshotRefresh() {
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: Date(timeIntervalSinceNow: 60), userInfo: nil) { err in
            if let err = err {
                print(err)
            }
        }
    }

    func download() {
        let d = UserDefaults.shared
        let endpoint = Endpoint<[Build]>.builds(object: d.branch ?? d.project, offset: 0, limit: 20)
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
        let s = CLKComplicationServer.sharedInstance()
        s.activeComplications?.forEach {
            s.reloadTimeline(for: $0)
        }
        scheduleSnapshotRefresh()
        scheduleBackgroundRefresh()
    }
}
