//
//  VCS+Image.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

extension VCS {

    var icon: UIImage {
        return UIImage(named: "icon-\(rawValue)")!
    }
}
