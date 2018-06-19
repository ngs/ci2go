//
//  BranchesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class BranchesViewController: UITableViewController {

    var project: Project? {
        didSet {
            branches = project?.branches.sorted() ?? []
        }
    }
    var branches: [Branch] = []

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = indexPath.section == 0 ? "All Branches" : branches[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            UserDefaults.shared.project = project
        } else {
            UserDefaults.shared.branch = branches[indexPath.row]
        }
        dismiss(animated: true, completion: nil)
    }

}
