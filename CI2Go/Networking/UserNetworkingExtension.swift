//
//  UserNetworkingExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/3/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

extension User {
    class func me(token: String? = nil) -> Observable<User> {
        let realm = try! Realm()
        let client = CircleAPIClient(token: token)
        return client.get("me").doOn(onNext: { user in
            autoreleasepool {
                try! realm.write {
                    realm.add(user, update: true)
                    let name = user.name, login = user.login, pusherId = user.pusherId
                    user.emails?.forEach { email in
                        let user = User()
                        user.name = name
                        user.email = email
                        user.login = login
                        user.pusherId = pusherId
                        realm.add(user, update: true)
                    }
                }
            }
        })
    }
}