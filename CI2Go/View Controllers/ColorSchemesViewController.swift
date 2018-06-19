//
//  ColorSchemesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import Dwifft

class ColorSchemesViewController: UITableViewController {

    var diffCalculator: TableViewDiffCalculator<String, ColorScheme>?

    var colorSchemes: [ColorScheme] = [] {
        didSet {
            diffCalculator?.sectionedValues = SectionedValues(
                values: colorSchemes,
                valueToSection: { String($0.name.first!).uppercased() },
                sortSections: { $0 < $1 },
                sortValues: { $0 < $1 })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: ColorSchemeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ColorSchemeTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        colorSchemes = ColorScheme.all
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ColorSchemeTableViewCell.identifier) as! ColorSchemeTableViewCell
        cell.colorScheme = diffCalculator?.value(atIndexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let scheme = diffCalculator?.value(atIndexPath: indexPath) else { return }
        scheme.apply()
        navigationController?.popViewController(animated: true)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return (0..<numberOfSections(in: tableView)).map {
            self.tableView(tableView, titleForHeaderInSection: $0) ?? ""
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return diffCalculator?.value(forSection: section)
    }
}
