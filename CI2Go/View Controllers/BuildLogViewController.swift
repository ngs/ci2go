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
    @IBOutlet weak var textView: UITextView!
    var pusherChannel: PusherChannel?
    var buildAction: BuildAction?
    var callbackIds: [String] = []
    var ansiHelper: AMR_ANSIEscapeHelper!
    let operationQueue = OperationQueue()
    @IBOutlet weak var scrollButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollButton: UIButton!
    var snapToBottom = true {
        didSet {
            if !snapToBottom {
                scrollButton.isHidden = false
            }
            let newBottom: CGFloat = snapToBottom ? scrollButton.frame.height + view.safeAreaInsets.bottom : -5
            scrollButtonBottomConstraint.constant =  newBottom
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ansiHelper = ColorScheme.current.createANSIEscapeHelper()
        title = buildAction?.name
        if buildAction?.status == .running {
            bindPusherEvents()
        } else {
            downloadLog()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = ""
        scrollButtonBottomConstraint.constant = scrollButton.frame.height
        scrollButton.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unbindPusherEvents()
    }

    func downloadLog() {
        guard let outputURL = buildAction?.outputURL else { return }
        NetworkActivityManager.start()
        showActivityIndicatorItem()
        URLSession.shared.dataTask(with: outputURL) { [weak self] (data, res, err) in
            NetworkActivityManager.stop()
            guard let `self` = self else { return }
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
                    self.navigationItem.rightBarButtonItem = nil
                })
            }
            }.resume()
        return
    }

    func showActivityIndicatorItem() {
        let av = UIActivityIndicatorView(activityIndicatorStyle: ColorScheme.current.activityIndicatorViewStyle)
        av.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: av)
    }

    func bindPusherEvents() {
        guard let pusherChannel = pusherChannel else { return }
        showActivityIndicatorItem()
        callbackIds.forEach {
            pusherChannel.unbind(.appendAction, callbackId: $0)
        }
        callbackIds = []
        callbackIds.append(pusherChannel.bind(.appendAction, { [weak self] data in
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
        }))
        callbackIds.append(pusherChannel.bind(.updateAction, { [weak self] data in
            data.forEach { datum in
                guard
                    let action = self?.buildAction,
                    let log = datum["log"] as? [String: Any],
                    let step = datum["step"] as? Int,
                    let index = datum["index"] as? Int,
                    let statusStr = log["status"] as? String,
                    let status = BuildAction.Status(rawValue: statusStr),
                    action.step == step &&
                        action.index == index &&
                        status != .running
                    else { return }
                self?.unbindPusherEvents()
            }
        }))
    }

    func unbindPusherEvents() {
        callbackIds.forEach {
            pusherChannel?.unbind(.appendAction, callbackId: $0)
        }
        callbackIds.removeAll()
        pusherChannel = nil
        operationQueue.cancelAllOperations()
        navigationItem.rightBarButtonItem = nil
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
                    if self?.snapToBottom == true {
                        textView.scrollToBottom(animated: true)
                    }
                })
            }
        }
    }

    func updateSnapToBottom() {
        guard textView.isOverflowed else { return }
        snapToBottom = textView.bottomOffsetY < 12
    }

    @IBAction func scrollToBottom(_ sender: Any? = nil) {
        scrollButton.setNeedsLayout()
        textView.scrollToBottom(animated: true)
        snapToBottom = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSnapToBottom()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSnapToBottom()
    }
}
