//
//  InterfaceController.swift
//  CI2GoWatch Extension
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import KeychainAccess
import FileKit

class BuildsInterfaceController: WKInterfaceController, WCSessionDelegate, SessionActivationResultDelegate {
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    @IBOutlet weak var placeholderGroup: WKInterfaceGroup!

    let maxBuilds = 20
    let fileOperationQueue = OperationQueue()
    var builds: [Build] = [] {
        didSet {
            DispatchQueue.main.async {
                self.updateList()
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        placeholderGroup.setHidden(true)
        interfaceTable.setHidden(false)
        if
            let _ = UserDefaults.shared.string(forKey: .colorScheme),
            builds.isEmpty,
            let cachedBuilds = [Build].fromCache() {
            self.builds = cachedBuilds
        }
        activateWCSession()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else {
            reload()
            return
        }
        requestActivation()
    }

    func requestActivation() {
        WCSession.default.sendMessage(WatchConnectivityFunction.activate.message, replyHandler: nil, errorHandler: nil)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let fn = WatchConnectivityFunction(message: message) else { return }
        self.session(session, didReceiveFunction: fn)
    }

    func session(_ sesion: WCSession, didReceiveActivationResult data: (String?, ColorScheme, Project?, Branch?)) {
        let (token, _, project, branch) = data
        guard let _ = token else {
            placeholderGroup.setHidden(false)
            interfaceTable.setHidden(true)
            return
        }
        loadBuilds(project: project, branch: branch)
    }

    @objc func reload() {
        let d = UserDefaults.shared
        let s = WCSession.default
        if s.activationState == .activated {
            requestActivation()
            return
        }
        loadBuilds(project: d.project, branch: d.branch)
    }

    func loadBuilds(project: Project?, branch: Branch?) {
        placeholderGroup.setHidden(true)
        interfaceTable.setHidden(false)
        let endpoint = Endpoint<[Build]>.builds(object: branch ?? project, offset: 0, limit: maxBuilds)
        URLSession.shared.dataTask(endpoint: endpoint) { [weak self] (builds, data, _, err) in
            guard let `self` = self, let builds = builds else { return }
            self.fileOperationQueue.addOperation {
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                    do {
                        try jsonString.write(to: type(of: builds).cacheFile.path)
                    } catch {
                        print(error)
                    }
                }
            }
            self.builds = Array(builds.prefix(self.maxBuilds))
            } .resume()
    }
    
    func updateList() {
        clearAllMenuItems()
        if builds.isEmpty { return }
        interfaceTable.setNumberOfRows(builds.count, withRowType: "default")
        for (i, build) in builds.enumerated() {
            let row = interfaceTable.rowController(at: i) as! BuildTableRowController
            row.build = build
        }
        addMenuItem(with: .repeat, title: "Reload", action: #selector(reload))
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        guard
            let row = table.rowController(at: rowIndex) as? BuildTableRowController,
            let build = row.build
            else { return nil }
        return build
    }

}
