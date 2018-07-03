//
//  SingleQuickLookDataSource.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/22.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import QuickLook

class SingleQuickLookDataSource: NSObject, QLPreviewControllerDataSource {
    class Item: NSObject, QLPreviewItem {
        let name: String
        let fileURL: URL
        init(name: String, fileURL: URL) {
            self.name = name
            self.fileURL = fileURL
        }

        var previewItemURL: URL? {
            return fileURL
        }

        var previewItemTitle: String? {
            return name
        }
    }

    let item: Item
    init(name: String, fileURL: URL) {
        item = Item(name: name, fileURL: fileURL)
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return item
    }

}
