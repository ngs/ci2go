//
//  BuildArtifactsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import Crashlytics
import Dwifft
import QuickLook

class BuildArtifactsViewController: UITableViewController, QLPreviewControllerDelegate {

    var build: Build?
    var path = "" {
        didSet {
            if path.isEmpty { return }
            title = path.components(separatedBy: "/").last
        }
    }
    var diffCalculator: TableViewDiffCalculator<Int, RowItem>?

    var artifacts: [Artifact] = []
    var quickLookDataSource: SingleQuickLookDataSource?

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: BuildArtifactTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: BuildArtifactTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArtifacts()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let nvc = segue.destination as? UINavigationController,
            let dataSource = sender as? SingleQuickLookDataSource
            else { return }
        let vc = QLPreviewController()
        vc.view.backgroundColor = ColorScheme.current.background
        vc.dataSource = dataSource
        vc.delegate = self
        nvc.viewControllers = [vc]
    }

    // MARK: -

    func loadArtifacts() {
        guard let build = self.build, artifacts.isEmpty else {
            refreshData()
            return
        }
        URLSession.shared.dataTask(endpoint: .artifacts(build: build)) { (artifacts, _, _, err) in
            guard let artifacts = artifacts else {
                Crashlytics.sharedInstance().recordError(err ?? APIError.noData)
                return
            }
            self.path = ""
            self.artifacts = artifacts
            self.refreshData()
            }.resume()
    }

    func refreshData() {
        let path = self.path
        let items: [RowItem] = artifacts.map { a in
            guard a.pathWithNodeIndex.starts(with: path) else { return nil }
            let comps = a.pathWithNodeIndex
                .dropFirst(path.count)
                .drop(while: { $0 == "/" })
                .components(separatedBy: "/")
            guard let name = comps.first else { return nil }
            return RowItem(name, artifact: comps.count == 1 ? a : nil)
            }.filter { $0 != nil }.map { $0! }.unique
        if items.count == 1 && items.first?.artifact == nil {
            self.path = "\(path)\(path.isEmpty ? "" : "/")\(items.first!.name)"
            refreshData()
            return
        }
        DispatchQueue.main.async {
            self.diffCalculator?.sectionedValues = SectionedValues<Int, RowItem>([(0, items)])
        }
    }

    func downloadAndQuickLook(name: String, artifact: Artifact) {
        if artifact.localPath.exists {
            showQuickLook(name: name, fileURL: artifact.localPath.url)
            return
        }
        if artifact.isInProgress {
            return
        }
        ArtifactDownloadManager.shared.download(artifact) { err in
            if let err = err {
                Crashlytics.sharedInstance().recordError(err)
            }
            self.tableView.reloadData()
        }
        tableView.reloadData()
    }

    func showQuickLook(name: String, fileURL: URL) {
        let dataSource = SingleQuickLookDataSource(name: name, fileURL: fileURL)
        quickLookDataSource = dataSource
        performSegue(withIdentifier: .showQuickLook, sender: dataSource)
    }

    // MARK: -

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let item = diffCalculator?.value(atIndexPath: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: BuildArtifactTableViewCell.identifier) as? BuildArtifactTableViewCell
            else { fatalError() }
        cell.item = item
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = diffCalculator?.value(atIndexPath: indexPath) else { fatalError() }
        if let artifact = item.artifact {
            downloadAndQuickLook(name: item.name, artifact: artifact)
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "BuildArtifactsViewController") as! BuildArtifactsViewController
        vc.path = "\(path)/\(item.name)"
        vc.artifacts = artifacts
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension BuildArtifactsViewController {
    struct RowItem: Equatable, Comparable {
        let artifact: Artifact?
        let name: String

        init(_ name: String, artifact: Artifact? = nil) {
            self.name = name
            self.artifact = artifact
        }

        static func ==(_ lhs: RowItem, _ rhs: RowItem) -> Bool {
            return lhs.name == rhs.name
        }

        static func < (lhs: RowItem, rhs: RowItem) -> Bool {
            if lhs.artifact == nil && rhs.artifact != nil {
                return true
            }
            return lhs.name < rhs.name
        }

        var icon: UIImage {
            if let _ = artifact {
                return #imageLiteral(resourceName: "file")
            }
            return #imageLiteral(resourceName: "folder")
        }
    }
}
