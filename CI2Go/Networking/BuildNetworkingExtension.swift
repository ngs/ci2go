//
//  BuildNetworkingExtension.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/4/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
#if os(iOS)
    import RealmResultsController
#endif

extension Build {
    func post(path: String) -> Observable<Build> {
        guard let apiPath = self.apiPath else { return Observable.never() }
        let client = CircleAPIClient()
        return client.post(apiPath).doOn(onNext: { build in
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    build.dup(self)
                    #if os(iOS)
                        realm.addNotified(build.steps, update: true)
                    #else
                        realm.add(build.steps, update: true)
                    #endif
                }
            }
        })
    }


    func get() -> Observable<Build> {
        guard let apiPath = self.apiPath else { return Observable.never() }
        let client = CircleAPIClient()
        return client.get(apiPath).doOn(onNext: { build in
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    build.dup(self)
                    let actions = build.steps.flatMap { $0.actions }
                    #if os(iOS)
                        self.notifyChange()
                        realm.addNotified(build.steps, update: true)
                        realm.addNotified(actions, update: true)
                    #else
                        realm.add(build.steps, update: true)
                        realm.add(actions, update: true)
                    #endif
                }

            }
        })
    }

    class func getRecent(offset: Int = 0, limit: Int = 30) -> Observable<[Build]> {
        return getList(path: "recent-builds", offset: offset, limit: limit)
    }
    class func getList(project project: Project, offset: Int = 0, limit: Int = 30) -> Observable<[Build]> {
        return getList(path: project.apiPath, offset: offset, limit: limit)
    }
    class func getList(branch branch: Branch, offset: Int = 0, limit: Int = 30) -> Observable<[Build]> {
        if let project = branch.project {
            return getList(project: project, offset: offset, limit: limit)
        }
        return Observable.never()
    }

    class func getList(offset offset: Int = 0, limit: Int = 30) -> Observable<[Build]> {
        let def = CI2GoUserDefaults.standardUserDefaults()
        if let branch = def.selectedBranch {
            return getList(branch: branch, offset: offset, limit: limit)
        }
        if let project = def.selectedProject {
            return getList(project: project, offset: offset, limit: limit)
        }
        return getRecent(offset, limit: limit)
    }

    class func getList(path path: String, offset: Int = 0, limit: Int = 30) -> Observable<[Build]> {
        let client = CircleAPIClient()
        let parameters = ["limit": limit, "offset": offset]
        return client.getList(path, parameters: parameters)
            .doOn(onNext: { (builds: [Build]) -> Void in
                autoreleasepool {
                    let realm = try! Realm()
                    let newBuilds = builds.filter{ !$0.id.isEmpty }
                    try! realm.write {
                        #if os(iOS)
                            realm.addNotified(newBuilds, update: true)
                        #else
                            realm.add(newBuilds, update: true)
                        #endif
                    }
                }
            })
    }
}
