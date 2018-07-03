//
//  Workflow.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct Workflow: Codable {
    let jobName: String
    let jobID: String
    let id: String
    let name: String
    let workspaceID: String
    let upstreamJobIDs: [String]

    enum CodingKeys: String, CodingKey {
        case jobName = "job_name"
        case jobID = "job_id"
        case id = "workflow_id"
        case name = "workflow_name"
        case workspaceID = "workspace_id"
        case upstreamJobIDs = "upstream_job_ids"
    }
}
