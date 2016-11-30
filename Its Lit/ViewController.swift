//
//  ViewController.swift
//  Its Lit
//
//  Created by Chandan Brown on 8/8/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import UIKit
import AVFoundation
import MultipeerConnectivity
import GoogleMobileAds
import Firebase
import MediaPlayer


class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate,  UINavigationControllerDelegate , UIImagePickerControllerDelegate, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    var animating : Bool = false
    let loginViewController = LoginViewController()
    var counter = 0
    var myMusicPlayer: MPMusicPlayerController?
    //MARK: - Objects
    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var itsLitImage: UIImageView!
    @IBOutlet weak var ItsLitButton: UIImageView!
    var myDictionary:NSDictionary = [:]
    var interstitial: GADInterstitial!
    var player: AVAudioPlayer?
    let url = Bundle.main.url(forResource: "We Lit", withExtension: "mp3")!
    let nameLabel = UILabel()

    //Variables for Peer to Peer.
    var browser   : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session   : MCSession!
    var peerID    : MCPeerID!
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        
        loadPeerToPeer()
        
        self.becomeFirstResponder()
        
        UINavigationBar.appearance().barTintColor = UIColor.rgb(254, green: 209, blue: 67)
        
        // get rid of black bar underneath navbar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // _
        
        view.backgroundColor = UIColor.rgb(254, green: 209, blue: 67)
        
        func canBecomeFirstResponder() -> Bool {
            return true
        }
        
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = "ca-app-pub-8446644766706278/3259335749"
        bannerView.rootViewController = self
        
    }
    
    //MARK: - Functions

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
    
    func checkIfUserIsLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign In (Removes Ads)", style: .done, target: self, action: #selector(signIn))
            navigationItem.leftBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
            navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmericanTypewriter-Bold", size: 18)!], for: UIControlState.normal)
            bannerView.load(GADRequest())
            
        } else {
            bannerView.isHidden = true
            fetchUserAndSetupNavBarTitle()
            let image = UIImage(named: "love")
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goToFriendsPage))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(handleLogout))
            navigationItem.leftBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 67)
            navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmericanTypewriter-Bold", size: 18)!], for: UIControlState.normal)
            setupMusicButton()
        }
    }
    
    var musicButton: UIButton = {
        let button = UIButton(type: .system)
        let origImage = UIImage(named: "Music")
        button.setImage(origImage, for: .normal)
       // button.addTarget(self, action: #selector(musicPicker), for: .touchUpInside)
        return button
    }()
    
    func setupMusicButton() {
        self.view.addSubview(musicButton)
        positionMusicButton()
    }
    
    func positionMusicButton() {
        musicButton.centerXAnchor.constraint(equalTo: peopleButton.centerXAnchor ).isActive = true
        musicButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func musicPicker() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: nil)
    }
    
    private func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        //User selected a/an item(s).
        myMusicPlayer = MPMusicPlayerController()
        
        if let player = myMusicPlayer{
            player.beginGeneratingPlaybackNotifications()
            
            player.setQueue(with: mediaItemCollection)
            player.play()
            
            
            mediaPicker.dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        print("User selected Cancel tell me what to do")
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func setupMusicPlayer() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        present(mediaPicker, animated: true, completion: nil)
    }
    func goToFriendsPage() {
        
        let friendsTableViewController = FriendsTableViewController()
        let navController = UINavigationController(rootViewController: friendsTableViewController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginViewController()
        loginController.viewController = self
        present(loginController, animated: true, completion: nil)
        
    }
    
    func signIn() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginViewController()
        loginController.viewController = self
        let navController = UINavigationController(rootViewController: loginController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func setupNavBarWithUser(_ user: User) {
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        // titleView.backgroundColor = UIColor.redColor()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor.rgb(254, green: 209, blue: 67)
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        
    }
    
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user)
            }
            
            }, withCancel: nil)
    }
    
    func playSound() {
        print ("Play")
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else {
                return }
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
        
    }
    
    func itsLitNoButton() {
        peopleButton.shake()
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
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
    
    
    // Called when a peer sends an NSData to us
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // This needs to run on the main queue
        DispatchQueue.main.async {
            self.itsLitNoButton()
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
    
    func loadPeerToPeer(){
        self.peerID  = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        self.assistant = MCAdvertiserAssistant(serviceType:"VBC-ShareCard", discoveryInfo:nil, session:self.session)
        self.assistant.start()
        self.browser = MCBrowserViewController(serviceType: "VBC-ShareCard", session: self.session)
        self.browser.delegate = self
    }
    
    
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        navigationController?.navigationBar.shake()
        ItsLitButton.shake()
        peopleButton.shake()
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
    
    var backgroundColours = [UIColor()]
    var backgroundLoop = 0
    
    let blueColor = UIColor(r: 110, g: 148, b: 208)
    let redColor = UIColor(r: 228, g: 36, b: 18)
    let defaultColor = UIColor(r: 254, g: 209, b: 67)
    let darkColor = UIColor(r: 38, g: 17, b: 5)
    
    @IBAction func changeBackground(gesture: UILongPressGestureRecognizer) {
        backgroundColours = [redColor, UIColor.darkGray, blueColor, UIColor.white, defaultColor]
        self.animateBackgroundColour()
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
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
                self.peopleButton.setImage(tintedImage, for: .normal)
                self.peopleButton.tintColor = UIColor.white
            }, completion: nil)
        } else if (counter == 3) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 1
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
            }, completion: nil)
            
        } else if (counter == 5) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 2
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
            }, completion: nil)
        } else if (counter == 7) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 3
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
                self.peopleButton.tintColor = UIColor.black
            }, completion: nil)
        } else if (counter == 9) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 4
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
            }, completion: nil)
        }
    } else {
        if (counter == 1) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 0
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
                self.peopleButton.setImage(tintedImage, for: .normal)
                self.peopleButton.tintColor = UIColor.white
                self.nameLabel.textColor = UIColor.white
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            }, completion: nil)
        } else if (counter == 3) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 1
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
            }, completion: nil)
            
        } else if (counter == 5) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 2
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
            }, completion: nil)
        } else if (counter == 7) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 3
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
                self.peopleButton.tintColor = UIColor.rgb(51, green: 21, blue: 1)
                self.navigationItem.titleView?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
                self.nameLabel.textColor = UIColor.rgb(51, green: 21, blue: 1)
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)

            }, completion: nil)
        } else if (counter == 9) {
            UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.backgroundLoop = 4
                self.view.backgroundColor =  self.backgroundColours[self.backgroundLoop]
            }, completion: nil)
        }
        
        }
        
        if counter > 9 {
            counter = 0
        }
}
   
    @IBAction func itsLit(_ sender: UIButton) {
        
        sendInfo()
        ItsLitButton.shake()
        rotateView()
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
//        if (device?.hasTorch)! {
//            do {
//                try device?.lockForConfiguration()
//                if (device?.torchMode == AVCaptureTorchMode.on) {
//                    stopSpinning()
//                    device?.torchMode = AVCaptureTorchMode.off
//                } else {
//                    do {
//                        try device?.setTorchModeOnWithLevel(1.0)
//                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//                    } catch {
//                        print(error)
//                    }
//                }
//                device?.unlockForConfiguration()
//            } catch {
//                print(error)
//            }
//        } else {
//            print ("The Mac is Lit")
//        }
//        
//        if self.session.connectedPeers.count == 6 {
//            playSound()
//        }
        
    }
    
    @IBAction func connectScreen(_ sender: AnyObject) {
        self.present(self.browser, animated: true, completion: nil)
        
    }
    
    
}

public extension UIView {

    func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTranslation translation : Float? = nil) {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        animation.repeatCount = count ?? 2
        animation.duration = (duration ?? 0.2)/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation ?? -15
        layer.add(animation, forKey: "shake")
    }    
}
