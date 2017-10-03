//
//  Notes+CoreDataProperties.swift
//  
//
//  Created by BAproductions on 10/1/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged public var amount: String?
    @NSManaged public var checked: Bool
    @NSManaged public var note: String?
    @NSManaged public var orderPosition: Double

}
