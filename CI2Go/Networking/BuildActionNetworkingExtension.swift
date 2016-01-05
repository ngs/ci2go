//
//  BuildActionNetworkingExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/2/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import Carlos

let cache = MemoryCacheLevel<String, NSString>() >>> DiskCacheLevel()

extension BuildAction {
    func downloadLog() -> Observable<String> {
        return Observable.create({ observer in
            guard let URL = self.outputURL else {
                return AnonymousDisposable {}
            }
            let cacheGet = cache.get(self.id)
            var req: Alamofire.Request?
            cacheGet.onCompletion { (value, error) in
                if let value = value {
                    observer.onNext(value as String)
                    observer.onCompleted()
                } else {
                    req = Alamofire.request(.GET, URL).responseJSON { res in
                        if let err = res.result.error {
                            return observer.onError(err)
                        }
                        if let json = res.result.value as? [[String: AnyObject]]
                            , value = json[0]["message"] as? String {
                                cache.set(value, forKey: self.id)
                                observer.onNext(value)
                        }
                        observer.onCompleted()
                    }
                }
            }
            return AnonymousDisposable {
                req?.cancel()
                cacheGet.cancel()
            }
        })
    }
}

