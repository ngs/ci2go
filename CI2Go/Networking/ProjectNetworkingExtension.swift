//
//  ProjectNetworkingExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/3/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

extension Project {
    class func getAll() -> Observable<[Project]> {
        let realm = try! Realm()
        let client = CircleAPIClient()
        let currentProjects = realm.objects(Project)
        return client.getList("projects").doOn(onNext: { (projects: [Project]) -> Void in
            autoreleasepool {
                try! realm.write {
                    realm.addNotified(projects, update: true)
                    currentProjects.forEach { prj in
                        if !projects.contains(prj) {
                            realm.deleteNotified(prj)
                        }
                    }
                }
            }
        })
    }

    func clearCache() -> Observable<Void> {
        let client = CircleAPIClient()
        return client.del("build-cache")
    }
}