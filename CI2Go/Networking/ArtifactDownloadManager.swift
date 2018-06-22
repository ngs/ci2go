//
//  ArtifactDownloadManager.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import KeychainAccess
import FileKit

class ArtifactDownloadManager {
    fileprivate static var _shared: ArtifactDownloadManager?
    let operationQueue = OperationQueue()

    static var shared: ArtifactDownloadManager {
        if let _shared = _shared {
            return _shared
        }
        _shared = ArtifactDownloadManager()
        return _shared!
    }

    func download(_ artifact: Artifact, completion: @escaping (Error?) -> Void) {
        do {
            try artifact.createProgressFile()
        } catch {
            DispatchQueue.main.async {
                completion(error)
            }
            return
        }
        operationQueue.addOperation {
            guard let token = Keychain.shared.token else {
                DispatchQueue.main.async {
                    completion(APIError.notLoggedIn)
                }
                return
            }
            var comps = URLComponents(url: artifact.downloadURL, resolvingAgainstBaseURL: false)!
            comps.queryItems = [URLQueryItem(name: "circle-token", value: token)]
            NetworkActivityManager.start()
            URLSession.shared.downloadTask(with: comps.url!) { (tmpFileURL, res, err) in
                NetworkActivityManager.stop()
                guard let tmpFileURL = tmpFileURL else {
                    try? artifact.unlinkProgressFile()
                    DispatchQueue.main.async {
                        completion(err ?? APIError.noData)
                    }
                    return
                }
                let path: Path = "\(tmpFileURL.path)"
                do {
                    try artifact.localPath.parent.createDirectory(withIntermediateDirectories: true)
                    try path.copyFile(to: artifact.localPath)
                    try artifact.unlinkProgressFile()
                    DispatchQueue.main.async { completion(nil) }
                } catch {
                    completion(error)
                }
                }.resume()
        }

    }

}
