//
//  CircleAPIClient.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/3/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class CircleAPIClient {
    let baseURL = NSURL(string: "https://circleci.com/api/v1/")!
    var token: String? = nil
    init(token: String? = nil) {
        self.token = token ?? CI2GoUserDefaults.standardUserDefaults().circleCIAPIToken
    }

    func apiURLForPath(path: String) -> NSURL {
        let URL = NSURL(string: path, relativeToURL: self.baseURL)!
        let urlComps = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true)!
        urlComps.queryItems = urlComps.queryItems ?? []
        if let token = token {
            let q = NSURLQueryItem(name: "circle-token", value: token)
            urlComps.queryItems?.append(q)
        }
        return urlComps.URL!
    }

    func post<T where T: Mappable, T: Object>(path: String, parameters: [String: AnyObject]? = nil) -> Observable<T> {
        return self.request(.POST, path, parameters: parameters, encoding: ParameterEncoding.JSON)
    }

    func get<T where T: Mappable, T: Object>(path: String, parameters: [String: AnyObject]? = nil) -> Observable<T> {
        return self.request(.GET, path, parameters: parameters, encoding: ParameterEncoding.URLEncodedInURL)
    }

    func getList<T where T: Mappable, T: Object>(path: String, keyPath: String? = nil, parameters: [String: AnyObject]? = nil) -> Observable<[T]> {
        return self.requestList(.GET, path, keyPath: keyPath, parameters: parameters, encoding: ParameterEncoding.URLEncodedInURL)
    }

    func del(path: String, parameters: [String: AnyObject]? = nil) -> Observable<Void> {
        return Observable.create({ observer in
            let req = self.createRequest(.DELETE, path, parameters: parameters, encoding: .URLEncodedInURL, headers: nil)
            req.responseString(completionHandler: { res in
                if let error = res.result.error {
                    observer.onError(error)
                } else {
                    observer.onNext()
                    observer.onCompleted()
                }
            })
            return AnonymousDisposable { req.cancel() }
        })
    }

    func request<T where T: Mappable, T: Object>(method: Alamofire.Method, _ path: String,
        parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil) -> Observable<T> {
            return Observable.create({ observer in
                let req = self.createRequest(method, path, parameters: parameters, encoding: encoding, headers: headers)
                req.responseObject { (res: Response<T, NSError>) in
                    if let error = res.result.error {
                        observer.onError(error)
                        return
                    }
                    if let obj = res.result.value {
                        observer.onNext(obj)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "com.ci2go.error", code: 1, userInfo: nil))
                    }
                }
                return AnonymousDisposable { req.cancel() }
            })
    }

    func requestList<T where T: Mappable, T: Object>(method: Alamofire.Method, _ path: String,
        keyPath: String? = nil,
        parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil) -> Observable<[T]> {
            return Observable.create({ observer in
                let req = self.createRequest(method, path, parameters: parameters, encoding: encoding, headers: headers)
                let completionHandler = { (res: Response<[T], NSError>) -> Void in
                    if let error = res.result.error {
                        observer.onError(error)
                    }
                    if let obj = res.result.value {
                        observer.onNext(obj)
                    }
                    observer.onCompleted()
                }
                if let keyPath = keyPath {
                    req.responseArray(keyPath, completionHandler: completionHandler)
                } else {
                    req.responseArray(completionHandler)
                }
                return AnonymousDisposable { req.cancel() }
            })
    }

    func createRequest(method: Alamofire.Method, _ path: String,
        parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL,
        var headers: [String: String]? = nil) -> Alamofire.Request {
            headers = headers ?? [:]
            headers?["Accept"] = "application/json"
            let req = Alamofire.request(method, self.apiURLForPath(path).absoluteString, parameters: parameters, headers: headers)
            print(req.debugDescription)
            return req
    }
}