//
//  Note+CoreDataProperties.swift
//  Notes
//
//  Created by Bart Jacobs on 06/02/16.
//  Copyright © 2016 Bart Jacobs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Note {

    @NSManaged var title: String?
    @NSManaged var content: String?
    @NSManaged var createdAt: NSTimeInterval
    @NSManaged var updatedAt: NSTimeInterval

}
