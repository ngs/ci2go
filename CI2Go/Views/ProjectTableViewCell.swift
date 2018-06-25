//
//  ProjectTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/20.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class ProjectTableViewCell: CustomTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vcsIconImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    var project: Project? {
        didSet {
            nameLabel.text = project?.name
            usernameLabel.text = project?.username
            vcsIconImageView.image = project?.vcs.icon
        }
    }
}
