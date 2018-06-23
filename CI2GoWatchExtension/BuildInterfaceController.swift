//
//  BuildInterfaceController.swift
//  CI2GoWatchExtension
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import WatchKit
import Foundation

class BuildInterfaceController: WKInterfaceController {
    @IBOutlet weak var branchLabel: WKInterfaceLabel!
    @IBOutlet weak var buildNumLabel: WKInterfaceLabel!
    @IBOutlet weak var repoLabel: WKInterfaceLabel!
    @IBOutlet weak var statusGroup: WKInterfaceGroup!
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var commitMessageLabel: WKInterfaceLabel!
    @IBOutlet weak var authorLabel: WKInterfaceLabel!
    @IBOutlet weak var branchIcon: WKInterfaceImage!
    @IBOutlet weak var timeLabel: WKInterfaceLabel!

    var colorScheme: ColorScheme?

    var build: Build? {
        didSet {
            guard
                let build = build,
                let colorScheme = colorScheme
                else { return }
            statusGroup.setBackgroundColor(colorScheme.badge(status: build.status))
            statusLabel.setText(build.status.humanize)
            repoLabel.setText(build.project.path)
            let numText = "#\(build.number)"
            buildNumLabel.setText(numText)
            setTitle(numText)
            branchLabel.setText(build.branch?.name)
            commitMessageLabel.setText(build.body)
            authorLabel.setText(build.user?.name)
            timeLabel.setText(build.timestamp?.timeAgoSinceNow)
            clearAllMenuItems()
            addMenuItem(with: .repeat, title: "Retry", action: #selector(retryBuild))
            if build.status == .running || build.status == .scheduled {
                addMenuItem(with: .decline, title: "Cancel", action: #selector(cancelBuild))
            }
        }
    }

    override func awake(withContext context: Any?) {
        guard let context = context as? SegueContext else {
            return
        }
        colorScheme = context.colorScheme
        build = context.build
    }

    @objc func retryBuild() {
        guard let build = build else { return }
        URLSession.shared.dataTask(endpoint: .retry(build: build)) { [weak self] (build, _, _, _) in
            guard let build = build else { return }
            DispatchQueue.main.async {
                self?.build = build
            }
        }.resume()
    }

    @objc func cancelBuild() {
        guard let build = build else { return }
        URLSession.shared.dataTask(endpoint: .cancel(build: build)) { [weak self] (build, _, _, _) in
            guard let build = build else { return }
            DispatchQueue.main.async {
                self?.build = build
            }
            }.resume()
    }
}
