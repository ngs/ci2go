//
//  BuildActionsViewController+Actions.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import Crashlytics
import MBProgressHUD

extension BuildActionsViewController {

    func loadBuild() {
        guard let build = self.build, !isLoading else {
            return
        }
        isLoading = true
        URLSession.shared.dataTask(endpoint: .get(build: build)) { [weak self] (build, _, _, _) in
            self?.isLoading = false
            self?.build = build
            }.resume()
    }

    func retryBuild(ssh: Bool = false) {
        guard
            let build = build,
            let nvc = navigationController
            else { return }
        let hud = MBProgressHUD.showAdded(to: nvc.view, animated: true)
        hud.animationType = .fade
        hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        hud.backgroundView.style = .solidColor
        hud.label.text = "Rerunning job"
        URLSession.shared.dataTask(endpoint: .retry(build: build, ssh: ssh)) { [weak self] (build, _, _, err) in
            DispatchQueue.main.async {
                let crashlytics = Crashlytics.sharedInstance()
                hud.mode = .customView
                hud.hide(animated: true, afterDelay: 1)
                guard let build = build else {
                    hud.label.text = "Failed to rerun job"
                    hud.icon = .warning
                    crashlytics.recordError(err ?? APIError.noData)
                    return
                }
                hud.label.text = "Job queued!"
                hud.icon = .success
                guard
                    let storyboard = self?.storyboard,
                    let viewController = storyboard.instantiateViewController(
                        withIdentifier: "BuildActionsViewController")
                        as? BuildActionsViewController
                    else { return }
                viewController.build = build
                nvc.pushViewController(viewController, animated: true)
            }
            }.resume()
    }

    func cancelBuild() {
        guard
            let build = build,
            let nvc = navigationController
            else { return }
        let hud = MBProgressHUD.showAdded(to: nvc.view, animated: true)
        hud.animationType = .fade
        hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        hud.backgroundView.style = .solidColor
        hud.label.text = "Canceling job"
        URLSession.shared.dataTask(endpoint: .cancel(build: build)) { [weak self] (build, _, _, err) in
            DispatchQueue.main.async {
                let crashlytics = Crashlytics.sharedInstance()
                hud.mode = .customView
                hud.hide(animated: true, afterDelay: 1)
                guard let build = build else {
                    hud.label.text = "Failed to cancel job"
                    hud.icon = .warning
                    crashlytics.recordError(err ?? APIError.noData)
                    return
                }
                hud.label.text = "Job canceled!"
                hud.icon = .success
                self?.build = build
            }
            }.resume()
    }
}
