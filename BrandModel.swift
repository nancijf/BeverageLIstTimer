//
//  BrandModel.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 9/13/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData

class BrandModel: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var favorite: Bool

}
