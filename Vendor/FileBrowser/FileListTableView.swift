//
//  FlieListTableView.swift
//  FileBrowser
//
//  Created by Roy Marmelstein on 14/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

extension FileListViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: UITableViewDataSource, UITableViewDelegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active {
            return 1
        }
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return filteredFiles.count
        }
        return sections[section].count
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].count == 0 ? 0 : 30
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sections[section].count == 0 { return nil }
        let v = UIView(), s = ColorScheme()
        let label = UILabel(frame: CGRectMake(0, 0, 0, 30))
        label.backgroundColor = UIColor.clearColor()
        label.textColor = s.foregroundColor()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.font = UIFont(name: "Helvetica Neue Bold Italic", size: 14)
        label.sizeToFit()
        label.frame = CGRect(origin: CGPointMake(10, 7), size: label.frame.size)
        v.addSubview(label)
        v.backgroundColor = s.foregroundColor()?.colorWithAlphaComponent(0.1)
        return v
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "FileCell"
        var cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) {
            cell = reuseCell
        }
        cell.selectionStyle = .Blue
        let selectedFile = fileForIndexPath(indexPath)
        cell.textLabel?.text = selectedFile.displayName
        cell.textLabel?.textColor = ColorScheme().foregroundColor()
        cell.imageView?.image = selectedFile.type.image()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedFile = fileForIndexPath(indexPath)
        searchController.active = false
        if selectedFile.isDirectory {
            let fileListViewController = FileListViewController(initialPath: selectedFile.filePath)
            fileListViewController.didSelectFile = didSelectFile
            self.navigationController?.pushViewController(fileListViewController, animated: true)
        }
        else {
            if let didSelectFile = didSelectFile {
                self.dismiss()
                didSelectFile(selectedFile)
            }
            else {
                let filePreview = previewManager.previewViewControllerForFile(selectedFile, fromNavigation: true)
                self.navigationController?.pushViewController(filePreview, animated: true)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.active {
            return nil
        }
        if sections[section].count > 0 {
            return collation.sectionTitles[section]
        }
        else {
            return nil
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if searchController.active {
            return nil
        }
        return collation.sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if searchController.active {
            return 0
        }
        return collation.sectionForSectionIndexTitleAtIndex(index)
    }
    
    
}