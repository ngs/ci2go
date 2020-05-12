//
//  UIMenu.Identifier+custom.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2020/05/12.
//  Copyright © 2020 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIMenu.Identifier {
    static var reload: UIMenu.Identifier {
        return UIMenu.Identifier("com.ci2go.menu.Reload")
    }
    static var back: UIMenu.Identifier {
        return UIMenu.Identifier("com.ci2go.menu.Back")
    }
    static var navigation: UIMenu.Identifier {
        return UIMenu.Identifier("com.ci2go.menu.Navigation")
    }
}
