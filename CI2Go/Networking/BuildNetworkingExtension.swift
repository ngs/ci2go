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
import FileKit
import Crashlytics

extension Build {

    enum APIAction: String {
        case Retry = "retry"
        case Cancel = "cancel"
    }

    func post(path: APIAction, clearCache: Bool = false) -> Observable<Build> {
        guard let apiPath = self.apiPath else { return Observable.never() }
        let client = CircleAPIClient()
        var apiAction: Observable<Build> = client.post("\(apiPath)/\(path.rawValue)")
        if let projectPath = project?.apiPath where clearCache {
            apiAction = Observable.combineLatest(client.del(projectPath + "/build-cache"), apiAction) { ($1) }
        }
        return apiAction.doOn(onNext: { build in
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    build.branch = self.branch
                    build.project = self.project
                    build.retryOf = self
                    #if os(iOS)
                        realm.addNotified(build, update: true)
                    #else
                        realm.add(build, update: true)
                    #endif
                }
            }
        })
    }

    func getSteps() -> Observable<[BuildStep]> {
        guard let apiPath = self.apiPath else { return Observable.never() }
        let client = CircleAPIClient()
        return client.getList(apiPath, keyPath: "steps").doOn(onNext: { steps in
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    var currentSectionType: String?
                    var sectionIndex = 0
                    steps.forEach { step in
                        guard let actionType = step.tempActions.first?.actionType else { return }
                        currentSectionType = currentSectionType ?? actionType
                        step.build = self
                        step.updateId()
                        step.tempActions.forEach { a in
                            currentSectionType = currentSectionType ?? actionType
                            if currentSectionType != actionType {
                                sectionIndex++
                                currentSectionType = actionType
                            }
                            a.buildStep = step
                            let actionType = a.actionType
                            a.actionType = String(format: "%05d:%@", sectionIndex, actionType)
                            a.updateId()
                        }
                    }
                    let actions = steps.flatMap { $0.tempActions.map{ $0.dup() } }
                    #if os(iOS)
                        realm.addNotified(actions, update: true)
                    #else
                        realm.add(actions, update: true)
                    #endif
                }
            }
        })

    }

    func getArtifacts() -> Observable<[BuildArtifact]> {
        guard let apiPath = apiPath else { return Observable.never() }
        let client = CircleAPIClient()
        return client.getList("\(apiPath)/artifacts").doOn(onNext: { artifacts in
            let realm = try! Realm()
            try! realm.write {
                let build = self.dup()
                let newArtifacts: [BuildArtifact] = artifacts.map { a in
                    let artifact: BuildArtifact = a.dup()
                    artifact.build = build
                    do {
                        try artifact.localPath.parent.createDirectory(withIntermediateDirectories: true)
                        if !artifact.localPath.exists {
                            try artifact.localPath.createFile()
                            try artifact.localPath.setWebLocation(artifact.url)
                        }
                    } catch let error {
                        print(error)
                        if let error = error as? FileKitError {
                            Crashlytics.sharedInstance().recordError(NSError(
                                domain: "com.ci2go.fileKitError",
                                code: error._code,
                                userInfo: [
                                    "description": error.description,
                                    "message": error.message]),
                                withAdditionalUserInfo: [:])
                        }
                    }
                    return artifact
                }
                #if os(iOS)
                    realm.addNotified(newArtifacts, update: true)
                #else
                    realm.add(newArtifacts, update: true)
                #endif
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
