//
//  Item+CoreDataClass.swift
//  CollectionView
//
//  Created by Jordan Zucker on 10/11/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = NSDate()
    }

}
