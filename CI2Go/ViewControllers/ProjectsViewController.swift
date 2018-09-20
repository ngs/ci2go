//
//  ProjectsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import Dwifft
import Crashlytics
import FileKit

class ProjectsViewController: UITableViewController {
    static let allCellIdentifier = "AllProjectsCell"

    var diffCalculator: TableViewDiffCalculator<String, Project?>?
    var isLoading = false

    var projects: [Project] = [] {
        didSet {
            DispatchQueue.main.async { self.refreshData() }
        }
    }

    var cacheFile: TextFile {
        return TextFile(path: Path.userDocuments + "projects.json")
    }

    // MARK: -

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ColorScheme.current.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: LoadingCell.identifier, bundle: nil),
            forCellReuseIdentifier: LoadingCell.identifier)
        tableView.register(
            UINib(nibName: ProjectTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: ProjectTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        isLoading = true
        projects = []
        tableView.reloadData()
        DispatchQueue.global().async {
            let decoder = JSONDecoder()
            guard
                let data = (try? self.cacheFile.read())?.data(using: .utf8),
                let projects = (try? decoder.decode([Project].self, from: data))
                else {
                    self.loadProjects(force: true)
                    return
            }
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(false)
                self.projects = projects
                self.refreshData()
                UIView.setAnimationsEnabled(true)
                self.loadProjects(force: true)
            }
        }
    }

    // MARK: -

    func loadProjects(force: Bool = false) {
        if isLoading && !force {
            return
        }
        isLoading = true
        let cacheFile = self.cacheFile
        URLSession.shared.dataTask(endpoint: .projects) { [weak self] (projects, data, _, err) in
            guard let projects = projects, let data = data else {
                Crashlytics.sharedInstance().recordError(err ?? APIError.noData)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                try? jsonString |> cacheFile
            }
            self?.isLoading = false
            self?.projects = projects
            }.resume()
    }

    func refreshData() {
        let values: [Project?] = [nil] + (projects as [Project?])
        diffCalculator?.sectionedValues = SectionedValues<String, Project?>(
            values: values,
            valueToSection: { project in
                guard
                    let name = project?.name,
                    let first = name.first
                    else { return "" }
                return String(first).lowercased()
        }, sortSections: { (lhs, rhs) in
            return  lhs < rhs
        }, sortValues: { (lhs, rhs) in
            guard let lhs = lhs else { return true }
            guard let rhs = rhs else { return false }
            return lhs < rhs
        })
        if let indexPath = tableView.indexPathsForVisibleRows?.first, indexPath.section == 0 {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    // MARK: -

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, sender) {
        case let (viewController as BranchesViewController, cell as ProjectTableViewCell):
            viewController.project = cell.project
            return
        case let (viewController as BuildsViewController, _ as UITableViewCell):
            viewController.selected = (nil, nil)
            return
        default:
            break
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return (0..<numberOfSections(in: tableView)).map {
            self.tableView(tableView, titleForHeaderInSection: $0) ?? ""
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return diffCalculator?.value(forSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if isLoading && projects.isEmpty {
                return tableView.dequeueReusableCell(withIdentifier: LoadingCell.identifier)!
            }
            return tableView.dequeueReusableCell(withIdentifier: ProjectsViewController.allCellIdentifier)!
        }
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProjectTableViewCell.identifier) as? ProjectTableViewCell
            else { fatalError() }
        cell.project = diffCalculator?.value(atIndexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell as? ProjectTableViewCell {
            performSegue(withIdentifier: .showBranches, sender: cell)
            return
        }
        performSegue(withIdentifier: .unwindSegue, sender: cell)
    }
}
