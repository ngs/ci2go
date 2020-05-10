//
//  BuildArtifactsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import Dwifft
import QuickLook
import FileKit

class BuildArtifactsViewController: UITableViewController, QLPreviewControllerDelegate {

    var build: Build?
    var path = "" {
        didSet {
            if path.isEmpty { return }
            let title = path.components(separatedBy: "/").last
            DispatchQueue.main.async {
                self.title = title
            }
        }
    }
    var diffCalculator: TableViewDiffCalculator<Int, RowItem>?
    var isLoading = false
    var artifacts: [Artifact] = []
    var quickLookDataSource: SingleQuickLookDataSource?

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: BuildArtifactTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: BuildArtifactTableViewCell.identifier)
        tableView.register(
            UINib(nibName: LoadingCell.identifier, bundle: nil),
            forCellReuseIdentifier: LoadingCell.identifier)
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
        let controller = QLPreviewController()
        controller.dataSource = dataSource
        controller.delegate = self
        nvc.viewControllers = [controller]
    }

    // MARK: -

    func loadArtifacts() {
        guard let build = self.build, artifacts.isEmpty else {
            refreshData()
            return
        }
        if isLoading {
            return
        }
        isLoading = true
        refreshData()
        URLSession.shared.dataTask(endpoint: .artifacts(build: build)) { [weak self] (artifacts, _, _, err) in
            self?.isLoading = false
            guard let artifacts = artifacts else {
                Crashlytics.crashlytics().record(error: err ?? APIError.noData)
                return
            }
            self?.path = ""
            self?.artifacts = artifacts
            self?.refreshData()
        }.resume()
    }

    func refreshData() {
        if isLoading {
            self.path = ""
            DispatchQueue.main.async {
                self.diffCalculator?.sectionedValues = SectionedValues<Int, RowItem>([(0, [RowItem(isLoading: true)])])
            }
            return
        }
        let path = self.path
        let items: [RowItem] = artifacts.map { artifact in
            guard artifact.pathWithNodeIndex.starts(with: path) else { return nil }
            let comps = artifact.pathWithNodeIndex
                .dropFirst(path.count)
                .drop(while: { $0 == "/" })
                .components(separatedBy: "/")
            guard let name = comps.first else { return nil }
            return RowItem(name, artifact: comps.count == 1 ? artifact : nil)
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
        ArtifactDownloadManager.shared.download(artifact) { [weak self] err in
            if let err = err {
                Crashlytics.crashlytics().record(error: err)
            }
            self?.tableView.reloadData()
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
        guard let item = diffCalculator?.value(atIndexPath: indexPath) else { fatalError() }
        if item.isLoading {
            return tableView.dequeueReusableCell(withIdentifier: LoadingCell.identifier)!
        }
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: BuildArtifactTableViewCell.identifier)
            as? BuildArtifactTableViewCell
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
        guard let controller = storyboard?.instantiateViewController(
            withIdentifier: "BuildArtifactsViewController") as? BuildArtifactsViewController
            else { fatalError() }
        controller.path = "\(path)/\(item.name)"
        controller.artifacts = artifacts
        navigationController?.pushViewController(controller, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard
            let item = diffCalculator?.value(atIndexPath: indexPath),
            let artifact = item.artifact,
            artifact.localPath.exists else {
                return UISwipeActionsConfiguration(actions: [])
        }
        let action = UIContextualAction(style: .normal, title: nil) { (_, _, complete) in
            DispatchQueue.global().async {
                do {
                    try artifact.localPath.deleteFile()
                    DispatchQueue.main.async { [weak tableView] in
                        tableView?.reloadRows(at: [indexPath], with: .fade)
                        complete(true)
                    }
                } catch {
                    complete(false)
                }
            }
        }
        action.backgroundColor = .systemRed
        action.image = #imageLiteral(resourceName: "trash")
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension BuildArtifactsViewController {
    struct RowItem: Equatable, Comparable {
        let artifact: Artifact?
        let name: String
        let isLoading: Bool

        init(_ name: String = "", artifact: Artifact? = nil, isLoading: Bool = false) {
            self.name = name
            self.artifact = artifact
            self.isLoading = isLoading
        }

        static func == (_ lhs: RowItem, _ rhs: RowItem) -> Bool {
            return lhs.name == rhs.name && lhs.isLoading == rhs.isLoading
        }

        static func < (lhs: RowItem, rhs: RowItem) -> Bool {
            if lhs.artifact == nil && rhs.artifact != nil {
                return true
            }
            return lhs.name < rhs.name
        }

        var icon: UIImage {
            return artifact != nil ? #imageLiteral(resourceName: "file") : #imageLiteral(resourceName: "folder")
        }
    }
}
