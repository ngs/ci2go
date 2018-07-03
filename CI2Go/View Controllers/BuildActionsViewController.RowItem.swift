//
//  BuildActionsViewController.RowItem.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

extension BuildActionsViewController {
    struct RowItem: Equatable, Comparable {
        let action: BuildAction?
        let isConfiguration: Bool
        let isArtifacts: Bool
        let sshInfo: SSHInfo?

        init(
            action: BuildAction? = nil,
            isConfiguration: Bool = false,
            isArtifacts: Bool = false,
            sshInfo: SSHInfo? = nil) {
            self.action = action
            self.isConfiguration = isConfiguration
            self.isArtifacts = isArtifacts
            self.sshInfo = sshInfo
        }

        static func == (_ lhs: RowItem, _ rhs: RowItem) -> Bool {
            if let lobj = lhs.action, let robj = rhs.action {
                return lobj == robj
            }
            if let lobj = lhs.sshInfo, let robj = rhs.sshInfo {
                return lobj == robj
            }
            return lhs.isConfiguration == rhs.isConfiguration && lhs.isArtifacts == rhs.isArtifacts
        }

        static func < (lhs: RowItem, rhs: RowItem) -> Bool {
            if let lobj = lhs.action, let robj = rhs.action {
                return lobj < robj
            }
            if let lobj = lhs.sshInfo, let robj = rhs.sshInfo {
                return lobj < robj
            }
            return lhs.isConfiguration == rhs.isConfiguration && lhs.isArtifacts == rhs.isArtifacts
        }

        var cellIdentifier: String {
            if isConfiguration {
                return "ConfigurationCell"
            }
            if isArtifacts {
                return "ArtifactsCell"
            }
            if sshInfo != nil {
                return "SSHCell"
            }
            return BuildActionTableViewCell.identifier
        }

        var segueIdentifier: SegueIdentifier {
            if isConfiguration {
                return .showBuildConfig
            }
            if isArtifacts {
                return .showBuildConfig
            }
            return .showBuildLog
        }
    }
}
