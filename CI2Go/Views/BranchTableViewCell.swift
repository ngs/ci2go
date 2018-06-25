//
//  BranchTableViewCell.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/20.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class BranchTableViewCell: CustomTableViewCell {
    var branch: Branch? {
        didSet {
            textLabel?.text = branch?.name ?? "All Branches"
        }
    }
}
