//
//  URL+CoreDataClass.swift
//  OWT_Swift
//
//  Created by Matthias BUREL on 03.03.19.
//  Copyright © 2019 Matthias BUREL. All rights reserved.
//

import Foundation
import CoreData

class URLObject:NSManagedObject {
    
    var uid: String?
    var date: Date?
    var url: String?
    var token: String?
    var dns: String?
    var isDemo = false
    
}
