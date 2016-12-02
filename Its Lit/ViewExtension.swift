//
//  ViewExtension.swift
//  Its Lit
//
//  Created by Chandan Brown on 11/30/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import Foundation
import Firebase

extension ViewController: UIImagePickerControllerDelegate {
    
    func profilePicUpdate() {
        
        let user = FIRAuth.auth()?.currentUser
        
            guard (user?.uid) != nil else {
                return
            }
            
            //successfully authenticated user
            let imageName = UUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            let metadata = FIRStorageMetadata()
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
                storageRef.put(uploadData, metadata: metadata, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabaseWithUID((user?.uid)!, values: values as [String : AnyObject])
                    }
                })
            }
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
        
            self.dismiss(animated: true, completion: nil)
        })
    }
    

    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        profilePicUpdate()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func animateBackgroundColour () {
        let origImage = UIImage(named: "people");
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        counter += 1
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            if (counter == 1) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 0
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
                    self.peopleButton.setImage(tintedImage, for: .normal)
                    self.peopleButton.tintColor = UIColor.white
                }, completion: nil)
            } else if (counter == 3) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 1
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                }, completion: nil)
                
            } else if (counter == 5) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 2
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                }, completion: nil)
            } else if (counter == 7) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 3
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
                    self.peopleButton.tintColor = UIColor.black
                }, completion: nil)
            } else if (counter == 9) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 4
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                }, completion: nil)
            }
        } else {
            if (counter == 1) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 0
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
                    self.peopleButton.setImage(tintedImage, for: .normal)
                    self.peopleButton.tintColor = UIColor.white
                    self.nameLabel.textColor = UIColor.white
                    self.musicButton.tintColor = UIColor.white
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                }, completion: nil)
            } else if (counter == 3) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 1
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                }, completion: nil)
                
            } else if (counter == 5) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 2
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                }, completion: nil)
            } else if (counter == 7) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 3
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                    self.navigationItem.leftBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
                    self.peopleButton.tintColor = UIColor.rgb(51, green: 21, blue: 1)
                    self.navigationItem.titleView?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
                    self.musicButton.tintColor = UIColor.rgb(51, green: 21, blue: 1)

                    self.nameLabel.textColor = UIColor.rgb(51, green: 21, blue: 1)
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
                    
                }, completion: nil)
            } else if (counter == 9) {
                UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.backgroundLoop = 4
                    UINavigationBar.appearance().barTintColor = self.backgroundColours[self.backgroundLoop]
                    self.profileImageView.backgroundColor = self.backgroundColours[self.backgroundLoop]
                    self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                }, completion: nil)
            }
            
        }
        
        if counter > 9 {
            counter = 0
        }
    }
    
    func rotateView() {
        if(!animating) {
            animating = true;
            spinWithOptions(options: UIViewAnimationOptions.curveEaseIn);
        }
    }
    
    func stopSpinning() {
        animating = false
    }
    
    func spinWithOptions(options: UIViewAnimationOptions) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: options, animations: { () -> Void in
            let val : CGFloat = CGFloat((M_PI / Double(2.0)));
            self.itsLitImage.transform = self.itsLitImage.transform.rotated(by: val)
        }) { (finished: Bool) -> Void in
            if(finished) {
                if(self.animating){
                    self.spinWithOptions(options: UIViewAnimationOptions.curveLinear)
                } else if (options != UIViewAnimationOptions.curveEaseOut) {
                    self.spinWithOptions(options: UIViewAnimationOptions.curveEaseOut)
                }
            }
            
        }
    }



}
