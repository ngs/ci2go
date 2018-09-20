//
//  ColorSchemesViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/18.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit
import Dwifft
import Crashlytics

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ColorScheme.current.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(
            UINib(nibName: ColorSchemeTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: ColorSchemeTableViewCell.identifier)
        diffCalculator = TableViewDiffCalculator(tableView: tableView)
        colorSchemes = ColorScheme.all
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return diffCalculator?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator?.numberOfObjects(inSection: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ColorSchemeTableViewCell.identifier) as? ColorSchemeTableViewCell
            else { fatalError() }
        cell.colorScheme = diffCalculator?.value(atIndexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let scheme = diffCalculator?.value(atIndexPath: indexPath) else { return }
        UIApplication.shared.setAlternateIconName(scheme.name) { err in
            if let err = err {
                Crashlytics.sharedInstance().recordError(err)
            }
        }
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
