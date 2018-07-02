//
//  LoginViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/29.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import WebKit
import KeychainAccess
import WatchConnectivity
import OnePasswordExtension
import Crashlytics

class LoginViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!

    var provider: AuthProvider!
    var foregroundObserver: NSObjectProtocol?

    func loadScript(name: String) -> String {
        return try! String(contentsOf: Bundle.main.url(forResource: name, withExtension: "js")!)
    }

    lazy var fetchTokenJS: String = {
        return loadScript(name: "fetchToken")
    }()

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard
            let url = navigationAction.request.url,
            Hostname(url: url) == .app,
            url.path.hasPrefix("/token/"),
            url.pathComponents.count > 2
            else {
                if let isMainFrame = navigationAction.targetFrame?.isMainFrame, !isMainFrame {
                    decisionHandler(.cancel)
                    return
                }
                let isCircle = Hostname(url: navigationAction.request.url)?.isCircleCI == true
                webView.alpha = isCircle ? 0 : 1
                webView.isUserInteractionEnabled = !isCircle
                navigationItem.rightBarButtonItem = UIBarButtonItem(activityIndicatorStyle: ColorScheme.current.activityIndicatorViewStyle)
                decisionHandler(.allow)
                return
        }
        let token = url.pathComponents[2]
        decisionHandler(.cancel)
        Keychain.shared.token = token
        WCSession.default.transferToken(token: token)
        performSegue(withIdentifier: .unwindSegue, sender: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard webView.url == nil else { return }
        let req = URLRequest(url: provider.url)
        webView.navigationDelegate = self
        webView.load(req)
        fillTotpToken()
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationWillEnterForeground,
            object: nil,
            queue: nil) { [weak self] _ in self?.fillTotpToken() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
        foregroundObserver = nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url, let host = Hostname(url: url) else { return }
        if host.isCircleCI {
            let js = fetchTokenJS + "('\(UIDevice.current.name) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))')"
            evaluateJavaScript(js)
            return
        }
        if host.isAuthProvider {
            fillTotpToken()
            if OnePasswordExtension.shared().isAppExtensionAvailable() {
                let item = UIBarButtonItem(image: #imageLiteral(resourceName: "onepassword-navbar"), style: .plain, target: self, action: #selector(openPasswordManager(_:)))
                navigationItem.rightBarButtonItem = item
                return
            }
        }
        navigationItem.rightBarButtonItem = nil
    }

    func fillTotpToken() {
        let pb = UIPasteboard.general
        guard
            let url = webView.url,
            let host = Hostname(url: url),
            host.isAuthProvider,
            let str = pb.string,
            isTOTP(str)
            else { return }
        switch host {
        case .github:
            guard url.path == "/sessions/two-factor" else {
                return
            }
            break
        case .bitbucket:
            let comps = url.pathComponents
            guard comps.count > 3 && comps[3] == "two-step-verification"  else {
                return
            }
            break
        default:
            fatalError()
        }
        UIPasteboard.general.items.removeAll()
        let js = self.loadScript(name: "totp-\(host.rawValue)") + "('\(str)')"
        self.evaluateJavaScript(js)

    }

    @objc func openPasswordManager(_ sender: Any?) {
        guard
            let url = webView.url,
            let host = Hostname(url: url),
            host.isAuthProvider
            else { return }
        OnePasswordExtension.shared().findLogin(forURLString: url.absoluteString, for: self, sender: sender) { (data, err) in
            if let err = err {
                Crashlytics.sharedInstance().recordError(err)
            }
            guard
                let data = data,
                let username = data["username"] as? String,
                let password = data["password"] as? String
                else { return }
            let js = self.loadScript(name: "login-\(host.rawValue)") + "('\(username)', '\(password)')"
            self.evaluateJavaScript(js)
        }
    }

    func evaluateJavaScript(_ script: String, completionHandler: ((Error?) -> Void)? = nil) {
        webView.evaluateJavaScript(script) { (res, err) in
            if let err = err {
                Crashlytics.sharedInstance().recordError(err)
                print("\(err), \(script)")
                completionHandler?(err)
                return
            }
            if let res = res as? String, res != "OK" {
                self.evaluateJavaScript(res, completionHandler: completionHandler)
                return
            }
            completionHandler?(nil)
        }

    }

}