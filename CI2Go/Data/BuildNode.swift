//
//  BuildNode.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/07/03.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation

struct BuildNode: Decodable {
    let publicIPAddress: String
    let port: Int
    let username: String
    let imageID: String?
    let isSSHEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case publicIPAddress = "public_ip_addr"
        case port = "port"
        case username = "username"
        case imageID = "image_id"
        case isSSHEnabled = "ssh_enabled"
        case server = "server"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if
            let server = try? values.decode(String.self, forKey: .server),
            let url = URL(string: "ssh://\(server)"),
            let host = url.host {
            publicIPAddress = host
            port = url.port ?? 22
            username = url.user ?? "circleci"
            imageID = nil
            isSSHEnabled = true
            return
        }
        publicIPAddress = try values.decode(String.self, forKey: .publicIPAddress)
        port = try values.decode(Int.self, forKey: .port)
        username = try values.decode(String.self, forKey: .username)
        imageID = try? values.decode(String.self, forKey: .imageID)
        isSSHEnabled = try values.decode(Bool.self, forKey: .isSSHEnabled)
    }

    var sshURL: URL {
        return URL(string: "ssh://\(username)@\(publicIPAddress):\(port)")!
    }

}
