//
//  Location.swift
//  Its Lit
//
//  Created by Chandan Brown on 1/13/17.
//  Copyright © 2017 Gaming Recess. All rights reserved.
//

import UIKit
import Firebase

class Location: NSObject {
    
    var name: String?
    var fromId: String?
    var latitude: String?
    var longitude: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func locationPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        latitude = dictionary["latitude"] as? String
        longitude = dictionary["longitude"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
    }
}
