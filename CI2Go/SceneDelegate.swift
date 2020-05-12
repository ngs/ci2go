//
//  SceneDelegate.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2020/05/11.
//  Copyright © 2020 LittleApps Inc. All rights reserved.
//

import UIKit
import KeychainAccess

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = windowScene.windows.first
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible
        splitViewController?.primaryBackgroundStyle = .sidebar

        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif

        #if DEBUG
        if CommandLine.arguments.contains("UITestingDarkModeEnabled") {
            window?.overrideUserInterfaceStyle = .dark
        }
        #endif
        window?.tintColor = .lightGray
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard
            let url = URLContexts.first?.url,
            let splitVC = window?.rootViewController as? MainSplitViewController,
            let viewController = splitVC.buildsViewController
            else { return }

        if let build = Build(inAppURL: url) ?? Build(webURL: url) {
            viewController.navigationController?.popToViewController(viewController, animated: false)
            viewController.performSegue(withIdentifier: .showBuildDetail, sender: build)
            return
        }
        guard
            url.host == inAppHost &&
                url.pathComponents.count == 3 &&
                url.pathComponents[1] == "token"
            else { return }
        let token = url.pathComponents[2]
        viewController.logout(showSettings: false)
        Keychain.shared.setAndTransfer(token: token)
        viewController.presentedViewController?.dismiss(animated: false, completion: nil)
        viewController.navigationController?.popToViewController(viewController, animated: false)
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            viewController.loadBuilds()
        }
    }

    // MARK: - Split View

    var splitViewController: UISplitViewController? {
        return window?.rootViewController as? UISplitViewController
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            let viewController = secondaryAsNavController.topViewController
            return viewController is BuildLogViewController || viewController is TextViewController
        }
        return false
    }
}
