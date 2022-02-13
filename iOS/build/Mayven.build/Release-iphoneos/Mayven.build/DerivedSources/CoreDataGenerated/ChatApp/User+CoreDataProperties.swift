//
//  User+CoreDataProperties.swift
//  
//
//  Created by Kevin Chan on 2021-04-22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var classOf: String?
    @NSManaged public var name: String?
    @NSManaged public var programCode: String?
    @NSManaged public var programName: String?
    @NSManaged public var school: String?
    @NSManaged public var schoolName: String?
    @NSManaged public var userId: String?
    @NSManaged public var username: String?

}

extension User : Identifiable {

}
