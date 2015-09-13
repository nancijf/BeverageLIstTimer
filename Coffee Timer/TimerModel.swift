//
//  TimerModel.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/29/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import Foundation
import CoreData

class TimerModel: NSManagedObject {
    
    @objc enum TimerType: Int32 {
        case Coffee = 0
        case Tea
    }
    
    @NSManaged var name: String?
    @NSManaged var duration: Int32
    @NSManaged var type: TimerType
    @NSManaged var displayOrder: Int32
    @NSManaged var favorite: Bool
    @NSManaged var brand: BrandModel
}
