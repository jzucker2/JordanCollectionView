//
//  Item+CoreDataProperties.swift
//  CollectionView
//
//  Created by Jordan Zucker on 10/11/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item");
    }

    @NSManaged public var title: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var value: String?

}
