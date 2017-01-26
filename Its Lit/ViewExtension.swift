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
    
    func setupMap() {
        if map.isHidden == false  {
            map.isHidden = true
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
        } else {
            map.isHidden = false
        }
        
        map.layer.cornerRadius = 30
    }
    
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
    
    func changeToRed() {
        let worldTintedImage = worldImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[0]
            self.view.backgroundColor =  self.backgroundColours[0]
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.nameLabel.textColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.worldButton.setImage(worldTintedImage, for: .normal)
            self.worldButton.tintColor = UIColor.white
            self.tapCounterLabel.tintColor = .white
        }, completion: nil)
    }
    
    func changeToGrey() {
        let worldTintedImage = worldImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[1]
            self.view.backgroundColor =  self.backgroundColours[1]
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.nameLabel.textColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.worldButton.setImage(worldTintedImage, for: .normal)
            self.worldButton.tintColor = UIColor.white
            self.tapCounterLabel.tintColor = .white
        }, completion: nil)
    }
    
    func changeToBlack() {
        let worldTintedImage = worldImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[2]
            self.view.backgroundColor =  self.backgroundColours[2]
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.nameLabel.textColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.worldButton.setImage(worldTintedImage, for: .normal)
            self.worldButton.tintColor = UIColor.white
            self.tapCounterLabel.tintColor = .white
        }, completion: nil)
        
    }
    
    func changeToWhite() {
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[3]
            self.view.backgroundColor =  self.backgroundColours[3]
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
            self.navigationItem.titleView?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
            self.nameLabel.textColor = UIColor.rgb(51, green: 21, blue: 1)
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
            self.worldButton.tintColor = UIColor.rgb(51, green: 21, blue: 1)
            self.tapCounterLabel.tintColor = .black
            
        }, completion: nil)
    }
    
    func changeToDefault() {
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[5]
            self.profileImageView.backgroundColor = self.backgroundColours[5]
            self.view.backgroundColor =  self.backgroundColours[5]
            self.tapCounterLabel.tintColor = .white
        }, completion: nil)
        
    }
    
    func changeToBlue() {
        let worldTintedImage = worldImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[4]
            self.view.backgroundColor =  self.backgroundColours[4]
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
            self.nameLabel.textColor = UIColor.white
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.worldButton.setImage(worldTintedImage, for: .normal)
            self.worldButton.tintColor = UIColor.white
            self.tapCounterLabel.tintColor = .white
        }, completion: nil)

    }
    func animateBackgroundColour () {
        changeToBlack()
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

func rotateWorldView() {
    if(!animating) {
        animating = true;
        spinWorldWithOptions(options: UIViewAnimationOptions.curveEaseIn);
    } else {
        animating = false
    }
}

func spinWorldWithOptions(options: UIViewAnimationOptions) {
    UIView.animate(withDuration: 10.0, delay: 0.0, options: options, animations: { () -> Void in
        let val : CGFloat = CGFloat((M_PI / Double(5.0)));
        self.worldButton.transform = self.worldButton.transform.rotated(by: val)
    }) { (finished: Bool) -> Void in
        if(finished) {
            if(self.animating){
                self.spinWorldWithOptions(options: UIViewAnimationOptions.curveLinear)
            } else if (options != UIViewAnimationOptions.curveEaseOut) {
                self.spinWorldWithOptions(options: UIViewAnimationOptions.curveEaseOut)
            }
        }
    }
}

}
