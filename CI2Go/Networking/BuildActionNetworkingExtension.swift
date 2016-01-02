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

extension BuildAction {
    func downloadLog() -> Observable<String> {
        return create({ observer in
            guard let URL = self.outputURL else {
                return AnonymousDisposable {}
            }
            let req = Alamofire.request(.GET, URL).responseString { res in
                if let err = res.result.error {
                    return observer.onError(err)
                }
                if let value = res.result.value {
                    observer.onNext(value)
                }
                observer.onCompleted()
            }
            return AnonymousDisposable { req.cancel() }
        })
    }
}

