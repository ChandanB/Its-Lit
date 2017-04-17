//
//  ViewExtension.swift
//  Its Lit
//
//  Created by Chandan Brown on 11/30/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import Firebase
import SCLAlertView
import MapKit
import GoogleMaps
import MultipeerConnectivity
import AVFoundation

extension ViewController: UIImagePickerControllerDelegate {
    
    // Start of Alerts
    func addAlert() {
        let appearance = SCLAlertView.SCLAppearance(
        kCircleIconHeight: 50,
        kTitleFont: UIFont(name: "AmericanTypewriter", size: 20)!,
        kTextFont: UIFont(name: "AmericanTypewriter", size: 14)!,
        kButtonFont: UIFont(name: "AmericanTypewriter-Bold", size: 14)!,
        showCloseButton: false
        )
        
        let alertViewIcon = UIImage(named: "ios emoji")
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = alertViewIcon
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("WHITE", backgroundColor: .black, textColor: .white) {
            self.changeToWhite()
            self.ogFireButton.animation = "slideUp"
            self.ogFireButton.duration = 2.0
            self.ogFireButton.animate()
        }
        alert.addButton("RED", backgroundColor: self.redColor, textColor: .white) {
            self.changeToRed()
            self.ogFireButton.animation = "slideUp"
            self.ogFireButton.duration = 2.0
            self.ogFireButton.animate()
        }
        alert.addButton("BLUE", backgroundColor: self.blueColor, textColor: .white) {
            self.changeToBlue()
            self.ogFireButton.animation = "slideUp"
            self.ogFireButton.duration = 2.0
            self.ogFireButton.animate()
        }
        alert.addButton("GOLD", backgroundColor: self.defaultColor, textColor: .white) {
            self.changeToDefault()
            self.ogFireButton.animation = "slideUp"
            self.ogFireButton.duration = 2.0
            self.ogFireButton.animate()
        }
        alert.addButton("GREY", backgroundColor: .darkGray, textColor: .white) {
            self.changeToGrey()
            self.ogFireButton.animation = "slideUp"
            self.ogFireButton.duration = 2.0
            self.ogFireButton.animate()
        }
        alert.addButton("DONE", backgroundColor: .white, textColor: .black) {
            self.ogFireButton.animation = "pop"
            self.ogFireButton.duration = 2.0
            self.ogFireButton.animate()
        }
        alert.showSuccess("OG FLAME", subTitle: "Let's Change The Background", colorStyle: 0x000000, circleIconImage: view.image, animationStyle: SCLAnimationStyle.bottomToTop)
    }
    
    func setupMap() {
        let appearance = SCLAlertView.SCLAppearance(
         kCircleIconHeight: 55,
         kTitleFont: UIFont(name: "AmericanTypewriter", size: 20)!,
         kTextFont: UIFont(name: "AmericanTypewriter", size: 14)!,
         kButtonFont: UIFont(name: "AmericanTypewriter-Bold", size: 14)!,
         showCloseButton: false
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        
        // Creat the subview
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        subView.superview?.autoresizesSubviews = false
        
        // Add MapView
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 14)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: subView.frame.width, height: subView.frame.height), camera: camera)
        
        let marker = GMSMarker()
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.position = camera.target
        marker.snippet = "It's Lit"
        marker.map = mapView
        
        mapView.layer.cornerRadius = 5
        subView.addSubview(mapView)
        
        // Add the subview to the alert's UI property
        let alertViewIcon = UIImage(named: "World Icon")
        alert.customSubview = subView
        alert.showInfo("Searching...", subTitle: "", duration: 10, colorStyle: 0xFFFFFF, circleIconImage: alertViewIcon)
    }
    
    // End of Alerts
    // Start of Animations
    
    func animateLighter() {
        self.bonusPointTextForOgFlame.isHidden = false
        self.bonusPointTextForOgFlame.alpha = 0
        ogFireButton.animation = "morph"
        ogFireButton.animate()
        
        UIView.animate(withDuration: 10, animations: {
            self.tapCounter += 1
            self.bonusPointTextForOgFlame.alpha = 1
            self.bonusPointTextForOgFlame.shakePoints()
        })
        
        UIView.animate(withDuration: 1, animations: {
            self.bonusPointTextForOgFlame.alpha = 0
        })
    }
    
    func changeToRed() {
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[0]
            self.view.backgroundColor =  self.backgroundColours[0]
            self.navigationItem.leftBarButtonItem?.tintColor = .white
            self.nameLabel.textColor = .white
            self.navigationItem.rightBarButtonItem?.tintColor = .white
            self.tapCounterLabel.textColor = .white
            self.bonusPointTextForOgFlame.textColor = .white
        }, completion: nil)
    }
    
    func changeToGrey() {
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[1]
            self.view.backgroundColor =  self.backgroundColours[1]
            self.navigationItem.leftBarButtonItem?.tintColor = .white
            self.nameLabel.textColor = .white
            self.navigationItem.rightBarButtonItem?.tintColor = .white
            self.tapCounterLabel.textColor = .white
            self.bonusPointTextForOgFlame.textColor = .white
        }, completion: nil)
    }
    
    func changeToBlack() {
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[2]
            self.view.backgroundColor =  self.backgroundColours[2]
            self.navigationItem.leftBarButtonItem?.tintColor = .white
            self.nameLabel.textColor = .white
            self.navigationItem.rightBarButtonItem?.tintColor = .white
            self.tapCounterLabel.textColor = self.defaultColor
            self.bonusPointTextForOgFlame.textColor = self.defaultColor
        }, completion: nil)
        
    }
    
    func changeToWhite() {
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[3]
            self.view.backgroundColor =  self.backgroundColours[3]
            self.navigationItem.leftBarButtonItem?.tintColor = self.darkColor
            self.navigationItem.titleView?.tintColor = self.darkColor
            self.nameLabel.textColor = self.darkColor
            self.navigationItem.rightBarButtonItem?.tintColor = self.darkColor
            self.tapCounterLabel.textColor =  self.darkColor
            self.bonusPointTextForOgFlame.textColor = self.darkColor
        }, completion: nil)
    }
    
    func changeToDefault() {
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[5]
            self.profileImageView.backgroundColor = self.backgroundColours[5]
            self.view.backgroundColor =  self.backgroundColours[5]
            self.tapCounterLabel.textColor = .white
            self.bonusPointTextForOgFlame.textColor = .white
        }, completion: nil)
        
    }
    
    func changeToBlue() {
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            UINavigationBar.appearance().barTintColor = self.backgroundColours[4]
            self.view.backgroundColor =  self.backgroundColours[4]
            self.navigationItem.leftBarButtonItem?.tintColor = .white
            self.nameLabel.textColor = .white
            self.navigationItem.rightBarButtonItem?.tintColor = .white
            self.tapCounterLabel.tintColor = .white
            self.bonusPointTextForOgFlame.textColor = .white
        }, completion: nil)
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
    
    func rotateView() {
        if(!animating) {
            animating = true;
            spinWithOptions(options: UIViewAnimationOptions.curveEaseIn);
        }
    }
    
    func stopSpinning() {
        animating = false
    }

    func addSwipe() {
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action:  #selector(self.swipeAnimations))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
    }
    
    func swipeAnimations(sender: UISwipeGestureRecognizer) {
        print(sender.direction)
        if sender.direction == .up {
            itsLitImage.animation = "pop"
            itsLitImage.animate()
        }
        if sender.direction == .down {
            stopSpinning()
            itsLitImage.animation = "fall"
            itsLitImage.animateToNext {
                self.itsLitImage.animation = "pop"
                self.itsLitImage.animateTo()
            }
        }
        if sender.direction == .left {
            stopSpinning()
            itsLitImage.animation = "slideRight"
            itsLitImage.animateToNext {
                self.itsLitImage.animation = "slideLeft"
                self.itsLitImage.animateTo()
            }
        }
        if sender.direction == .right {
            stopSpinning()
            itsLitImage.animation = "slideLeft"
            itsLitImage.animateToNext {
                self.itsLitImage.animation = "slideRight"
                self.itsLitImage.animateTo()
            }
        }
    }
    
    // End of Animations
    // Start of Peer to Peer
    
    func sendInfo() {
        if self.session.connectedPeers.count > 0 {
            let firstNameVar = "It's"
            let lastNameVar = "Lit"
            myDictionary = ["itemA" : "\(firstNameVar)", "itemB" : "\(lastNameVar)"]
            do {
                let data =  NSKeyedArchiver.archivedData(withRootObject: myDictionary)
                try self.session.send(data, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
            } catch let error as NSError {
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(ac, animated: true, completion: nil)
            }
        }
    }
    
    //Mark: PEER
    func loadPeerToPeer(_ user: User){
        self.peerID  = MCPeerID(displayName: user.name!)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        self.assistant = MCAdvertiserAssistant(serviceType:"VBC-ShareCard", discoveryInfo:nil, session:self.session)
        self.assistant.start()
        self.browser = MCBrowserViewController(serviceType: "VBC-ShareCard", session: self.session)
        self.browser.delegate = self
    }
    
    // Called when a peer sends an NSData to us
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // This needs to run on the main queue
        DispatchQueue.main.async {
            self.itsLitNoButton()
            self.tapCounter += 1
        }
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    // End of Peer to Peer
    // Start of Profile Pic Update
    
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
        picker.allowsEditing = true
        picker.delegate = self
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

    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        // Shake Animation
        navigationController?.navigationBar.shake()
        ItsLitButton.shake()
        
        if motion == .motionShake {
            sendInfo()
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            if (device?.hasTorch)! {
                do {
                    try device?.lockForConfiguration()
                    if (device?.torchMode == AVCaptureTorchMode.on) {
                        device?.torchMode = AVCaptureTorchMode.off
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                    } else {
                        
                        do {
                            try device?.setTorchModeOnWithLevel(1.0)
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        } catch {
                            print(error)
                        }
                    }
                    device?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
}
