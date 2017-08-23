//
//  CardsData.swift
//  Happy Days
//
//  Created by surendra kumar on 7/9/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import RealmSwift


class CardsData : Object {
    dynamic var id = "0"
    dynamic var task : String = ""
    dynamic var isDone : Bool = false
    dynamic var isNotificationON : Bool = false
    dynamic var date : NSDate = NSDate()
    dynamic var priority : Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
