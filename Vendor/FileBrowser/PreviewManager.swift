//
//  PreviewManager.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 16/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation
import QuickLook
import FileKit
import RxSwift
import MBProgressHUD

class PreviewManager: NSObject, QLPreviewControllerDataSource {

    var filePath: NSURL?

    let disposeBag = DisposeBag()

    func previewViewControllerForFile(file: FBFile, fromNavigation: Bool) -> UIViewController {

        if file.type == .PLIST || file.type == .JSON{
            let webviewPreviewViewContoller = WebviewPreviewViewContoller(nibName: "WebviewPreviewViewContoller", bundle: NSBundle(forClass: WebviewPreviewViewContoller.self))
            webviewPreviewViewContoller.file = file
            return webviewPreviewViewContoller
        }
        else {
            let previewTransitionViewController = PreviewTransitionViewController(nibName: "PreviewTransitionViewController", bundle: NSBundle(forClass: PreviewTransitionViewController.self))
            previewTransitionViewController.quickLookPreviewController.dataSource = self

            self.filePath = file.filePath
            if let filePathString = self.filePath?.path {
                let path = Path(filePathString)
                if let webloc = path.webLocation {
                    let v = AppDelegate.current.window!
                    let hud = MBProgressHUD(view: v)
                    v.addSubview(hud)
                    hud.animationType = MBProgressHUDAnimation.Fade
                    hud.dimBackground = true
                    hud.labelText = "Downloading File"
                    hud.show(true)
                    CircleAPIClient().downloadFile(webloc, localFilePath: path).subscribe(
                        onNext: { p in
                            print(p.percentage)
                        },
                        onError: { e in
                            hud.labelText = "Failed to Download File"
                            hud.customView = UIImageView(image: UIImage(named: "791-warning-hud"))
                            hud.mode = MBProgressHUDMode.CustomView
                            hud.hide(true, afterDelay: 1)
                            print(e)
                        },
                        onCompleted: {
                            hud.hide(true)
                            previewTransitionViewController.quickLookPreviewController.reloadData()
                        }
                        ).addDisposableTo(disposeBag)
                }
            }
            if fromNavigation == true {
                return previewTransitionViewController.quickLookPreviewController
            }
            return previewTransitionViewController
        }
    }


    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let item = PreviewItem()
        if let filePath = filePath {
            item.filePath = filePath
        }
        return item
    }

}

class PreviewItem: NSObject, QLPreviewItem {

    var filePath: NSURL?

    internal var previewItemURL: NSURL {
        if let filePath = filePath {
            return filePath
        }
        return NSURL()
    }

}
