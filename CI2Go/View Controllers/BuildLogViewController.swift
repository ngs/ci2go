//
//  BuildLogViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import PusherSwift
import Crashlytics
import MBProgressHUD

class BuildLogViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var textView: BuildLogTextView!
    var pusherChannel: PusherChannel?
    var buildAction: BuildAction?
    var callbackId: String?
    var ansiHelper: AMR_ANSIEscapeHelper!
    let operationQueue = OperationQueue()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ansiHelper = ColorScheme.current.createANSIEscapeHelper()
        title = buildAction?.name
        if buildAction?.status == .running {
            bindPusherEvent()
        } else {
            downloadLog()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let callbackId = callbackId {
            pusherChannel?.unbind(.appendAction, callbackId: callbackId)
        }
        pusherChannel = nil
        operationQueue.cancelAllOperations()
    }

    func downloadLog() {
        guard let outputURL = buildAction?.outputURL else { return }
        NetworkActivityManager.start()
        URLSession.shared.dataTask(with: outputURL) { (data, res, err) in
            NetworkActivityManager.stop()
            let decoder = JSONDecoder()
            guard
                let data = data,
                let logs = try? decoder.decode([BuildLog].self, from: data)
                else {
                    Crashlytics.sharedInstance().recordError(err ?? APIError.noData)
                    DispatchQueue.main.async {
                        let hud = MBProgressHUD.showAdded(to: self.navigationController?.view ?? self.view, animated: true)
                        hud.label.text = "Failed to load log"
                        hud.icon = .warning
                        hud.hide(animated: true, afterDelay: 2)
                    }
                    return
            }
            let str = logs.map { $0.message }.joined()
            let astr = self.ansiHelper.attributedString(withANSIEscapedString: str)
            DispatchQueue.main.async {
                self.textView.attributedText = astr
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.textView.scrollToBottom()
                })
            }
            }.resume()
        return
    }

    func bindPusherEvent() {
        guard let pusherChannel = pusherChannel else { return }
        if let callbackId = callbackId {
            pusherChannel.unbind(.appendAction, callbackId: callbackId)
        }
        callbackId = pusherChannel.bind(.appendAction, { [weak self] data in
            let rawOut = data.map { datum in
                guard
                    let index = datum["index"] as? Int,
                    let step = datum["step"] as? Int,
                    let out = datum["out"] as? [String: Any],
                    let message = out["message"] as? String,
                    let buildAction = self?.buildAction,
                    buildAction.index == index && buildAction.step == step
                    else { return "" }
                return message
                }.joined()
            self?.appendLog(string: rawOut)
        })
    }

    func appendLog(string: String) {
        if string.isEmpty { return }
        operationQueue.addOperation { [weak self] in
            DispatchQueue.main.sync {
                guard
                    let ansiHelper = self?.ansiHelper,
                    let textView = self?.textView,
                    let str = ansiHelper.attributedString(withANSIEscapedString: string),
                    let mstr = self?.textView.attributedText.mutableCopy() as? NSMutableAttributedString
                    else { return }
                mstr.append(str)
                textView.attributedText = mstr
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    textView.scrollIfNeeded()
                })
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let scrollView = scrollView as? BuildLogTextView else { return }
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y
        let height = scrollView.frame.height
        if contentHeight < height { return }
        let diff = contentHeight - offsetY - height
        scrollView.snapToBottom = diff <= 0
    }
}
