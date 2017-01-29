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
    
    var timestamp : NSNumber?
    var longitude : String?
    var latitude  : String?
    var fromId    : String?
    var name      : String?
    var toId      : String?
    
    func locationPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        timestamp = dictionary["timestamp"] as? NSNumber
        longitude = dictionary["longitude"] as? String
        latitude  = dictionary["latitude"]  as? String
        fromId    = dictionary["fromId"]    as? String
        toId      = dictionary["toId"]      as? String
    }
}
