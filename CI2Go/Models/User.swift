//
//  User.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class User: CI2GoManagedObject {

    @NSManaged public var email: String?
    @NSManaged public var login: String?
    @NSManaged public var name: String?
    @NSManaged public var authedCommits: NSSet?
    @NSManaged public var builds: NSSet?
    @NSManaged public var commits: NSSet?
    @NSManaged public var pushedBranches: NSSet?

}
