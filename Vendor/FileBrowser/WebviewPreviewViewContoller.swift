//
//  WebviewPreviewViewContoller.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 16/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import WebKit
import FileKit
import RxSwift
import MBProgressHUD

/// Webview for rendering items QuickLook will struggle with.
class WebviewPreviewViewContoller: UIViewController {
    
    var webView = WKWebView()

    var file: FBFile? {
        didSet {
            self.title = file?.displayName
            self.processForDisplay()
        }
    }

    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(webView)
        
        // Add share button
        let shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareFile")
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.frame = self.view.bounds
    }
    
    //MARK: Share
    
    func shareFile() {
        guard let file = file else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [file.filePath], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }

    //MARK: Processing

    let disposeBag = DisposeBag()
    
    func processForDisplay() {
        guard let filePathString = file?.filePath.path else { return }
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
                    self.processForDisplay()
                }
            ).addDisposableTo(disposeBag)
        } else {
            processRawFileForDisplay()
        }
    }

    func processRawFileForDisplay() {
        guard let file = file, data = NSData(contentsOfURL: file.filePath) else { return }

        var rawString: String?

        // Prepare plist for display
        if file.type == .PLIST {
            do {
                if let plistDescription = try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil).description {
                    rawString = plistDescription
                }
            } catch {}
        }

            // Prepare json file for display
        else if file.type == .JSON {
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                if NSJSONSerialization.isValidJSONObject(jsonObject) {
                    let prettyJSON = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: .PrettyPrinted)
                    var jsonString = String(data: prettyJSON, encoding: NSUTF8StringEncoding)
                    // Unescape forward slashes
                    jsonString = jsonString?.stringByReplacingOccurrencesOfString("\\/", withString: "/")
                    rawString = jsonString
                }
            } catch {}
        }

        // Default prepare for display
        if rawString == nil {
            rawString = String(data: data, encoding: NSUTF8StringEncoding)
        }

        // Convert and display string
        if let convertedString = convertSpecialCharacters(rawString) {
            let htmlString = "<html><head><meta name='viewport' content='initial-scale=1.0, user-scalable=no'></head><body><pre>\(convertedString)</pre></body></html>"
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
    

    // Make sure we convert HTML special characters
    // Code from https://gist.github.com/mikesteele/70ae98d04fdc35cb1d5f
    func convertSpecialCharacters(string: String?) -> String? {
        guard let string = string else {
            return nil
        }
        var newString = string
        let char_dictionary = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'"
        ];
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.stringByReplacingOccurrencesOfString(escaped_char, withString: unescaped_char, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        }
        return newString
    }
}
