//
//  LoginController+handlers.swift
//  It's Lit
//
//  Created byChandan on 7/4/16.
//  Copyright © 2016 TurnApp. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleRegister() {
        
        FIRDatabase.database().reference().child("usernames").runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
            var userName = self.nameTextField.text
            
            if currentData.value == nil {
                currentData.value = userName
            } else {
                self.nameTextField.text = ""
                userName = ""
            }
            
            currentData.value = userName
            self.nameTextField.text = currentData.value as! String?
            return FIRTransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        guard
            let password = passwordTextField.text,
            let name  = nameTextField.text,
            let email = emailTextField.text
            else {
                print("Form is not valid")
                return
        }
        
        if name == "" {
            self.errorTextField.isHidden = false
            self.errorTextField.text = ("Username Taken")
        } else {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                self.profileImageView.shake()
                self.errorTextField.isHidden = false
                if (self.passwordTextField.text?.characters.count)! < 6 {
                    self.errorTextField.text = ("Password has to be atleast 6 characters")
                }
                print(error as Any)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                self.profileImageView.shake()
                print(err as Any)
                return
            }
            
            self.viewController?.fetchUserAndSetupNavBarTitle()
            self.viewController?.navigationItem.title = values["name"] as? String
            let user = User()
            
            //may crash if keys don't match
            user.setValuesForKeys(values)
            let username = FIRDatabase.database().reference().child("usernames")
            let values = [user.name!: uid]
            username.updateChildValues(values)
            self.viewController?.viewDidLoad()
            self.viewController?.setupNavBarWithUser(user)
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
