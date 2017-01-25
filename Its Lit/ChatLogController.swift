//
//  File.swift
//  It's  Lit
//
//  Created by Chandan Brown on 7/24/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let viewController: ViewController? = nil
    let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    let cellId = "cellId"
    var ref: FIRDatabaseReference?
    var databaseHandle: FIRDatabaseHandle?
    var databaseHandleReceiving: FIRDatabaseHandle?
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
            observeFriendRequest()
        }
    }
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Friend", style: .plain, target: self, action: #selector(addFriend))
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        FIRDatabase.database().reference().child("Lit").child(uid).child(toId).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                print("Failed to delete litness:", error as Any)
                return
            }
        })
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.rgb(230, green: 230, blue: 230)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        setupKeyboardObservers()
    }
    
    func observeFriendRequest() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        //Check if any request received
        self.databaseHandleReceiving = FIRDatabase.database().reference().child("Friend").child(toId).child(uid).observe(.childAdded, with: { (snapshot) in
            
            FIRDatabase.database().reference().child("Friend").child(toId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if (snapshot.value as? [String: AnyObject]) != nil {
                    FIRDatabase.database().reference().child("Friend").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if (snapshot.value as? [String: AnyObject]) != nil {
                            let image = UIImage(named: "love")
                            let tintedImage = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: tintedImage, style: .plain, target: self, action: nil)
                            self.navigationItem.rightBarButtonItem?.tintColor = .red
                        } else {
                            let alert = UIAlertController(title: "Friend Request Received", message: "This user wants to be your friend! Add them to get lit anywhere, anytime.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "It's Lit", style: UIAlertActionStyle.default, handler: { action in
                                self.friendAdded()
                            }))
                            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
            })
            
        }, withCancel: nil)
        
        //Confirm Request Was Sent
        databaseHandle = FIRDatabase.database().reference().child("Friend").child(uid).child(toId).observe(.childAdded, with: { (snapshot) in
            if (snapshot.value as? [String: AnyObject]) == nil {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Waiting", style: .plain, target: self, action: nil)
            }
        })
    }
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        databaseHandle = FIRDatabase.database().reference().child("Lit").child(uid).child(toId).observe(.childAdded, with: { (snapshot) in
            self.itsLitNoButton()
            FIRDatabase.database().reference().child("Lit").child(uid).child(toId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete litness:", error as Any)
                    return
                }
            })
            
            FIRDatabase.database().reference().child("Lit").child(toId).child(uid).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete litness:", error as Any)
                    return
                }
            })
        })
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            FIRDatabase.database().reference().child("Lit").child(uid).child(toId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete litness:", error as Any)
                    return
                }
            })
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func itsLitNoButton() {
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                } else {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
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
    
    func addFriend(){
        let alert = UIAlertController(title: "Add Friend?", message: "Do you want to add this user to your friend list?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "It's Lit", style: UIAlertActionStyle.default, handler: { action in
            self.friendAdded()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func friendAdded() {
        
        let ref = FIRDatabase.database().reference().child("Friends")
        let childRef = ref.childByAutoId()
        let toId = self.user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let friendRef = FIRDatabase.database().reference().child("Friend").child(fromId).child(toId)
        
        let friends = childRef.key
        // let recipientRef = FIRDatabase.database().reference().child("Friend").child(toId).child(fromId)
        
        friendRef.updateChildValues([friends: true])
        //  recipientRef.updateChildValues([friends: true])
        
    }
    
    func invite() {
        let ref = FIRDatabase.database().reference().child("Lit")
        let childRef = ref.childByAutoId()
        let toId = self.user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let litRef = FIRDatabase.database().reference().child("Lit").child(fromId).child(toId)
        let litId = childRef.key
        
        FIRDatabase.database().reference().child("Lit").child(fromId).child(toId).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                print("Failed to delete litness:", error as Any)
                return
            }
        })
        
        if (device?.torchMode == AVCaptureTorchMode.off) && messages == [] {
            let properties = ["text": "Tap the flashlight to send a lit message!"]
            self.sendMessageWithProperties(properties as [String : AnyObject])
            
        }
        
        var properties = ["text": inputContainerView.inputTextField.text!]
        if properties == ["text": ""] {
            if (device?.torchMode == AVCaptureTorchMode.off) && messages == [] {
                properties = ["text": "Tap the flashlight to send a lit message!"]
                self.sendMessageWithProperties(properties as [String : AnyObject])
            } else {
                properties = ["text": "It's Lit!"]
            }
        } else {
            sendMessageWithProperties(properties as [String : AnyObject])
        }
        
        litRef.updateChildValues([litId: 1])
        
        let recipientLitRef = FIRDatabase.database().reference().child("Lit").child(toId).child(fromId)
        recipientLitRef.updateChildValues([litId: 1])
        
        FIRDatabase.database().reference().child("Lit").child(fromId).child(toId).removeValue(completionBlock: { (error, ref) in
            if error != nil {
                print("Failed to delete litness:", error as Any)
                return
            }
        })
        
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = ((notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = ((notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
        let message = messages[(indexPath as NSIndexPath).item]
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        if let text = message.text {
            //a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
        }
        return cell
    }
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //outgoing yellow
            cell.bubbleView.backgroundColor = .white
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            
            //incoming gray
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
            cell.bubbleView.backgroundColor = .red
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = false
            cell.profileImageView.addGestureRecognizer(tapGestureRecognizer)
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[(indexPath as NSIndexPath).item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
            
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func handleSend() {
        let properties = ["text": inputContainerView.inputTextField.text!]
        if properties == ["text": ""] {
        } else {
            sendMessageWithProperties(properties as [String : AnyObject])
        }
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp]
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as Any)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        performZoomInForStartingImageView(imageView)
    }
    
    //my custom zooming logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .clear
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .clear
            blackBackgroundView?.alpha = 1
            blackBackgroundView?.addBlurEffect()
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.inputContainerView.alpha = 0
                self.blackBackgroundView?.alpha = 1
                
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
            })
        }
    }
    
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}
