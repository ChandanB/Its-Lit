//
//  ViewExtension.swift
//  Its Lit
//
//  Created by Chandan Brown on 11/30/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import Foundation
import Firebase

extension DefaultUserViewController: UIImagePickerControllerDelegate {
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            self.dismiss(animated: true, completion: nil)
        })
    }
}
