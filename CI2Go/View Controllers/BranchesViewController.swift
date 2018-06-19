//
//  BranchesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class BranchesViewController: UITableViewController {
    let allCellIdentifier = "AllBranchCell"

    var project: Project? {
        didSet {
            branches = project?.branches.sorted() ?? []
        }
    }
    var branches: [Branch] = []

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, sender) {
        case let (vc as BuildsViewController, cell as BranchTableViewCell):
            vc.selected = (nil, cell.branch)
            return
        case let (vc as BuildsViewController, _):
            vc.selected = (project, nil)
            return
        default:
            break
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return project?.branches.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: allCellIdentifier)!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: BranchTableViewCell.identifier) as! BranchTableViewCell
        cell.branch = branches[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            UserDefaults.shared.project = project
        } else {
            UserDefaults.shared.branch = branches[indexPath.row]
        }
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: .unwindSegue, sender: cell)
    }

}
