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

class BuildsInterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    @IBOutlet weak var placeholderGroup: WKInterfaceGroup!

    let maxBuilds = 20
    var colorScheme: ColorScheme?
    var endpoint: Endpoint<[Build]>?
    var builds: [Build] = []
    
    override func willActivate() {
        super.willActivate()
        placeholderGroup.setHidden(true)
        interfaceTable.setHidden(false)
        updateList()
        loadBuilds()
        activateWCSession()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard activationState == .activated else { return }
        requestActivation { (token, colorScheme, project, branch) in
            let object: EndpointConvertable? = project ?? branch
            let endpoint = Endpoint<[Build]>.builds(object: object, offset: 0, limit: self.maxBuilds)
            self.endpoint = endpoint
            self.colorScheme = colorScheme
            Keychain.shared.token = token
            guard let _ = token else {
                self.placeholderGroup.setHidden(false)
                self.interfaceTable.setHidden(true)
                return
            }
            self.loadBuilds()
        }
    }

    @objc func reload() {
        loadBuilds()
    }

    func loadBuilds() {
        guard let endpoint = endpoint else { return }
        URLSession.shared.dataTask(endpoint: endpoint) { [weak self] (builds, data, _, err) in
            guard let `self` = self, let builds = builds else { return }
            self.builds = Array(builds.prefix(self.maxBuilds))
            self.updateList()
            } .resume()
    }
    
    func updateList() {
        clearAllMenuItems()
        guard let colorScheme = colorScheme, !builds.isEmpty else { return }
        interfaceTable.setNumberOfRows(builds.count, withRowType: "default")
        for (i, build) in builds.enumerated() {
            let row = interfaceTable.rowController(at: i) as! BuildTableRowController
            row.build = build
            row.colorScheme = colorScheme
            row.updateViews()
        }
        addMenuItem(with: .repeat, title: "Reload", action: #selector(reload))
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        guard
            let row = table.rowController(at: rowIndex) as? BuildTableRowController,
            let build = row.build,
            let colorScheme = row.colorScheme
            else { return nil }
        return SegueContext(build: build, colorScheme: colorScheme)
    }
    
}
