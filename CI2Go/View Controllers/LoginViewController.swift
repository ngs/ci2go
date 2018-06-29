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

class LoginViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!

    enum Provider: Int {
        case github = 0
        case bitbucket = 1

        var name: String {
            switch self {
            case .github:
                return "GitHub"
            case .bitbucket:
                return "BitBucket"
            }
        }

        var image: UIImage {
            switch self {
            case .github:
                return #imageLiteral(resourceName: "github")
            case .bitbucket:
                return #imageLiteral(resourceName: "bitbucket")
            }
        }

        var url: URL {
            switch self {
            case .github:
                return URL(string: "https://circleci.com/login?return-to=https://circleci.com/account/api")!
            default:
                return URL(string: "https://circleci.com/bitbucket-login?return-to=https://circleci.com/account/api")!
            }
        }

        var label: String {
            return "Login with \(name)"
        }
    }

    var provider: Provider!

    lazy var fetchTokenJS: String = {
        return try! String(contentsOf: Bundle.main.url(forResource: "fetchToken", withExtension: "js")!)
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url, url.host == "circleci.com" else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        webView.evaluateJavaScript(fetchTokenJS + "('\(UIDevice.current.name) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))')")
    }

}
