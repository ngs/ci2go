//
//  UIMenuElement+custom.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2020/05/12.
//  Copyright © 2020 LittleApps Inc. All rights reserved.
//

import UIKit

extension UIMenuElement {
    static var navigate: UIMenu {
        return UIMenu(
            title: "Navigate",
            image: nil,
            identifier: .navigate,
            options: .destructive,
            children: [
                .back,
                .reload])
    }
    static var logout: UIMenu {
        return UIMenu(
            title: "Logout",
            image: nil,
            identifier: .logout,
            options: .displayInline,
            children: [.logoutCommand])
    }
    static var logoutCommand: UIKeyCommand {
        let command = UIKeyCommand(
            input: "L",
            modifierFlags: [.command, .shift, .alternate],
            action: #selector(AppDelegate.logoutAction(_:)))
        command.title = "Logout"
        command.discoverabilityTitle = "Logout"
        return command
    }
    static var back: UIKeyCommand {
        let command = UIKeyCommand(
            input: "[",
            modifierFlags: [.command],
            action: #selector(AppDelegate.backAction(_:)))
        command.title = "Back"
        command.discoverabilityTitle = "Back"
        return command
    }
    static var reload: UIKeyCommand {
        let command = UIKeyCommand(
            input: "R",
            modifierFlags: [.command],
            action: #selector(AppDelegate.reloadAction(_:)))
        command.title = "Reload"
        command.discoverabilityTitle = "Reload"
        return command
    }
}
