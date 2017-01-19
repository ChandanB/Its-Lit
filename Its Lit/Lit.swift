//
//  Lit.swift
//  Its Lit
//
//  Created by Chandan Brown on 11/24/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import Firebase

class Lit: NSObject {
    
    var fromId: String?
    var toId: String?
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
    }

}
