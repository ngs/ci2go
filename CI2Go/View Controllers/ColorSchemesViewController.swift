//
//  ColorSchemesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class ColorSchemesViewController: UITableViewController {

    var sections: Sections<ColorScheme>!

    override func viewDidLoad() {
        super.viewDidLoad()
        sections = ColorScheme.all.sectionized
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.numberOfObjects(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ColorSchemeTableViewCell
        cell.colorScheme = sections.object(at: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scheme = sections.object(at: indexPath)
        scheme.apply()
        navigationController?.popViewController(animated: true)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { $0.title! }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
