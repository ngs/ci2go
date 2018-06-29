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

    func loadScript(name: String) -> String {
        return try! String(contentsOf: Bundle.main.url(forResource: name, withExtension: "js")!)
    }

    lazy var fetchTokenJS: String = {
        return loadScript(name: "fetchToken")
    }()

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard
            let url = navigationAction.request.url,
            url.scheme == "ci2go",
            url.host == "ci2go.app",
            url.path.hasPrefix("/token/"),
            url.pathComponents.count > 2
            else {
                if let isMainFrame = navigationAction.targetFrame?.isMainFrame, !isMainFrame {
                    decisionHandler(.cancel)
                    return
                }
                let isCircle = navigationAction.request.url?.host == "circleci.com"
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
        let req = URLRequest(url: provider.url)
        webView.navigationDelegate = self
        webView.load(req)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url, let host = url.host else { return }
        if host == "circleci.com" {
            let js = fetchTokenJS + "('\(UIDevice.current.name) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))')"
            webView.evaluateJavaScript(js, completionHandler: { (res, err) in
                if let err = err {
                    Crashlytics.sharedInstance().recordError(err)
                }
            })
            return
        }
        if ["github.com", "bitbucket.org"].contains(host) && OnePasswordExtension.shared().isAppExtensionAvailable() {
            let item = UIBarButtonItem(image: #imageLiteral(resourceName: "onepassword-navbar"), style: .plain, target: self, action: #selector(openPasswordManager(_:)))
            navigationItem.rightBarButtonItem = item
            return
        }
        navigationItem.rightBarButtonItem = nil
    }

    @objc func openPasswordManager(_ sender: Any?) {
        guard
            let urlString = webView.url?.absoluteString,
            let host = webView.url?.host,
            ["github.com", "bitbucket.org"].contains(host)
            else { return }
        OnePasswordExtension.shared().findLogin(forURLString: urlString, for: self, sender: sender) { (data, err) in
            if let err = err {
                Crashlytics.sharedInstance().recordError(err)
            }
            guard
                let data = data,
                let username = data["username"] as? String,
                let password = data["password"] as? String
                else { return }
            let js = self.loadScript(name: "login-\(host)") + "('\(username)', '\(password)')"
            self.webView.evaluateJavaScript(js, completionHandler: { (res, err) in
                if let err = err {
                    Crashlytics.sharedInstance().recordError(err)
                }
                if let res = res as? String, res != "OK" {
                    self.webView.evaluateJavaScript(res, completionHandler: { (_, err) in
                        if let err = err {
                            Crashlytics.sharedInstance().recordError(err)
                        }
                    })
                }
            })
        }
    }

}
