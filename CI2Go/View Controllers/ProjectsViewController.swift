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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: LoadingCell.identifier, bundle: nil), forCellReuseIdentifier: LoadingCell.identifier)
        tableView.register(UINib(nibName: ProjectTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ProjectTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        let decoder = JSONDecoder()
        if
            let data = (try? cacheFile.read())?.data(using: .utf8),
            let projects = (try? decoder.decode([Project].self, from: data)) {
            UIView.setAnimationsEnabled(false)
            self.projects = projects
            refreshData()
            UIView.setAnimationsEnabled(true)
        } else {
            projects = []
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProjects()
    }

    // MARK: -

    func loadProjects() {
        if isLoading {
            return
        }
        isLoading = true
        URLSession.shared.dataTask(endpoint: .projects) { (projects, data, res, err) in
            guard let projects = projects, let data = data else {
                Crashlytics.sharedInstance().recordError(err ?? APIError.noData)
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                try? jsonString |> self.cacheFile
            }
            self.isLoading = false
            self.projects = projects
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
    }

    // MARK: -

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let vc = segue.destination as? BranchesViewController,
            let cell = sender as? ProjectTableViewCell
            else  { return }
        vc.project = cell.project
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
            return tableView.dequeueReusableCell(withIdentifier: "AllProjectsCell")!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ProjectTableViewCell.identifier) as! ProjectTableViewCell
        cell.project = diffCalculator?.value(atIndexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ProjectTableViewCell {
            performSegue(withIdentifier: .showBranches, sender: cell)
            return
        }
        UserDefaults.shared.project = nil
        UserDefaults.shared.branch = nil
        dismiss(animated: true, completion: nil)
    }
}
