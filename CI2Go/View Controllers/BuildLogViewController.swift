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

class BuildLogViewController: UIViewController {
    @IBOutlet weak var textView: BuildLogTextView!
    var pusherChannel: PusherChannel?
    var buildAction: BuildAction?
    var callbackId: String?
    var ansiHelper: AMR_ANSIEscapeHelper!

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
            guard
                let textView = self?.textView,
                let ansiHelper = self?.ansiHelper
                else { return }
            var rawOut = ""
            data.forEach { datum in
                guard
                    let index = datum["index"] as? Int,
                    let step = datum["step"] as? Int,
                    let out = datum["out"] as? [String: Any],
                    let message = out["message"] as? String,
                    let buildAction = self?.buildAction,
                    buildAction.index == index && buildAction.step == step
                    else { return }
                rawOut += message
            }
            guard
                let str = ansiHelper.attributedString(withANSIEscapedString: rawOut),
                let mstr = textView.attributedText.mutableCopy() as? NSMutableAttributedString
                else { return }
            mstr.append(str)
            self?.textView.attributedText = mstr
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let callbackId = callbackId {
            pusherChannel?.unbind(.appendAction, callbackId: callbackId)
        }
        pusherChannel = nil
    }
}
