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
import MapKit
import JSSAlertView
import Spring
import SCLAlertView

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate,  UINavigationControllerDelegate , MPMediaPickerControllerDelegate, CLLocationManagerDelegate {
    
    //MARK: - Objects In View
    
    @IBOutlet weak var smallItsLitButton: SpringImageView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var worldButton: UIButton!
    @IBOutlet weak var itsLitImage: SpringImageView!
    @IBOutlet weak var ItsLitButton: UIImageView!
    @IBOutlet weak var tapCounterLabel: UILabel!
    let profileImageView = SpringImageView()
    let titleView = UIView()
    let containerView = UIView()
    var viewController = self
    var interstitial: GADInterstitial!
    
    //MARK: - Objects
    var locationManager = CLLocationManager()
    var animating : Bool = false
    let loginViewController = LoginViewController()
    var myMusicPlayer: MPMusicPlayerController?
    var myDictionary:NSDictionary = [:]
    var player: AVAudioPlayer?
    let weLitSound = Bundle.main.url(forResource: "We Lit", withExtension: "mp3")!
    let itsLitSound = Bundle.main.url(forResource: "ItsLit", withExtension: "aiff")!
    let nameLabel = UILabel()
    var counter = 0
    var interactionCounter = 0
    var heldDownFor = 0
    var tapCounter = 0
    var locationsDictionary = [String: Location]()
    var users: [User?] = [] {
        didSet {
            observeFriendsAndSendLitness()
        }
    }
    
    var timer = Timer()
    var otherUser: User?
    var databaseHandleReceiving: FIRDatabaseHandle?
    @IBOutlet weak var tapLabel: UILabel!
    
    //MARK: - Colors and Animations
    var backgroundColours = [UIColor()]
    var backgroundLoop = 0
    let blueColor = UIColor(r: 110, g: 148, b: 208)
    let redColor = UIColor(r: 228, g: 36, b: 18)
    let defaultColor = UIColor(r: 254, g: 209, b: 67)
    let darkColor = UIColor(r: 38, g: 17, b: 5)
    let blackColor = UIColor.black
    let worldImage = UIImage(named: "World Icon")
    
    //Variables for Peer to Peer.
    var browser   : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session   : MCSession!
    var peerID    : MCPeerID!
    var litness = [Lit]()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itsLitImage.animation = "slideUp"
        itsLitImage.animate()
        
        UINavigationBar.appearance().barTintColor = UIColor.rgb(254, green: 209, blue: 67)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        view.backgroundColor = UIColor.rgb(254, green: 209, blue: 67)
        self.map.isHidden = true
        
        checkIfUserIsLoggedIn()
        loadPeerToPeer()
        
        self.becomeFirstResponder()
        func canBecomeFirstResponder() -> Bool {
            return true
        }
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference().child("User-Score").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let firScore = dictionary["Score"] as? Int
                self.tapCounter = firScore!
            }
        }, withCancel: nil)
        smallItsLitButton.isHidden = true
        smallItsLitButton.isUserInteractionEnabled = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countForInteraction), userInfo: nil, repeats: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(littleLitTapped))
        
        smallItsLitButton.addGestureRecognizer(tapGestureRecognizer)
        self.backgroundColours = [UIColor(r: 228, g: 36, b: 18), UIColor.darkGray, blackColor, UIColor.white, UIColor(r: 110, g: 148, b: 208), UIColor(r: 254, g: 209, b: 67)]

    }
    
    func littleLitTapped(sender: UITapGestureRecognizer) {
        smallItsLitButton.animation = "swing"
        smallItsLitButton.animate()
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "AmericanTypewriter", size: 20)!,
            kTextFont: UIFont(name: "AmericanTypewriter", size: 14)!,
            kButtonFont: UIFont(name: "AmericanTypewriter-Bold", size: 14)!,
            showCloseButton: true
        )
        let alertViewIcon = UIImage(named: "ios emoji")
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("WHITE", backgroundColor: .black, textColor: .white) {
            self.changeToWhite()
        }
        alert.addButton("RED", backgroundColor: self.redColor, textColor: .white) {
            self.changeToRed()
        }
        alert.addButton("BLUE", backgroundColor: self.blueColor, textColor: .white) {
            self.changeToBlue()
        }
        alert.addButton("GOLD", backgroundColor: self.defaultColor, textColor: .white) {
            self.changeToDefault()
        }
        alert.addButton("GREY", backgroundColor: .darkGray, textColor: .white) {
            self.changeToGrey()
        }
        alert.showSuccess("OG FLAME", subTitle: "Let's Change The Background", colorStyle: 0x000000, circleIconImage: alertViewIcon)
        
        // Upon displaying, change/close view
       // alertViewResponder.setTitle("Sup") // Rename title
       // alertViewResponder.setSubTitle("Choose Color") // Rename subtitle
      //  alertViewResponder.close() // Close view
    }
    
    func countForInteraction() {
        
        interactionCounter += 1
        
        if interactionCounter == 4 {
            if self.tapCounter > 1000 {
                smallItsLitButton.isHidden = false
                smallItsLitButton.animation = "fadeInUp"
                smallItsLitButton.animate()
                setupLabel()
            }
            view.isUserInteractionEnabled = true
            timer.invalidate()
        } else {
            updateUserTapCounter()
            view.isUserInteractionEnabled = false
        }
    }
    
    //MARK: - Background Functions
    
    //Check if logged in
    func checkIfUserIsLoggedIn() {
        
        // If user isn't logged in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            self.worldButton.isHidden = true
            setupNavBarWithoutUser()
            createAndLoadInterstitial()
            do {
                try FIRAuth.auth()?.signOut()
            } catch let logoutError {
                print(logoutError)
            }
            let loginController = LoginViewController()
            loginController.viewController = self
            let navController = UINavigationController(rootViewController: loginController)
            present(navController, animated: true, completion: nil)
            
        } else {
            
            view.isUserInteractionEnabled = false

            self.groupUsers(users as! [User])
            //  peopleButton.isHidden = true
            self.worldButton.isHidden = true
            profileImageView.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled = true
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            
            fetchUserAndSetupNavBarTitle()
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Friends", style: .plain, target: self, action: #selector(goToFriendsPage))
            navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmericanTypewriter-Bold", size: 18)!], for: UIControlState.normal)
            navigationItem.rightBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Connect", style: .done, target: self, action: #selector(connectScreen(_:)))
            navigationItem.leftBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 67)
            navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmericanTypewriter-Bold", size: 18)!], for: UIControlState.normal)
        }
    }
    
    // Fetch user
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
    
    func setupNavBarWithoutUser() {
        createAndLoadInterstitial()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign In", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.tintColor = .black
        profileImageView.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    // Setup Nav Bar with fetched user
    func setupNavBarWithUser(_ user: User) {
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        // titleView.backgroundColor = UIColor.redColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 15
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
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        
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
    
    func observeFriendsAndSendLitness() {
        
        //        let ref = FIRDatabase.database().reference().child("Litness")
        //        let toId = otherUser?.id!
        //        let fromId = FIRAuth.auth()!.currentUser!.uid
        //        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        //        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp]
        //
        //        //append properties dictionary onto values somehow??
        //        //key $0, value $1
        //
        //        childRef.updateChildValues(values) { (error, ref) in
        //            if error != nil {
        //                print(error as Any)
        //                return
        //            }
        //
        //            let userLitRef = FIRDatabase.database().reference().child("Litness").child(fromId).child(toId!)
        //
        //            let litId = childRef.key
        //            userLitRef.updateChildValues([litId: 1])
        //
        //            let recipientUserMessagesRef = FIRDatabase.database().reference().child("Litness").child(toId!).child(fromId)
        //            recipientUserMessagesRef.updateChildValues([litId: 1])
        //        }
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        databaseHandleReceiving = FIRDatabase.database().reference().child("Friend").child(uid).observe(.value, with: { (snapshot) in
            let litId = snapshot.key
            let litRef = FIRDatabase.database().reference().child("Litness").child(litId)
            litRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                self.litness.append(Lit(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
                    self.itsLitNoButton()
                })
            }, withCancel: nil)
        })
    }
    
    func groupUsers(_ users: [User]) {
        self.users = users
    }
    
    //MARK: - Functions
    @IBAction func showMap(_ sender: Any) {
        setupMap()
        //  rotateWorldView()
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func goToFriendsPage() {
        let friendsTableViewController = FriendsTableViewController()
        let navController = UINavigationController(rootViewController: friendsTableViewController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        do {
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
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
    
    
    @IBAction func changeBackground(gesture: UILongPressGestureRecognizer) {
        
        
        if self.tapCounter >= 500 {
        UIView.animate(withDuration: 1.0, animations: { self.itsLitImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1) }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.itsLitImage.transform = CGAffineTransform.identity
                self.changeToBlack()
            }
         })
        }
    }
    
    //MARK: - Functions for Flash
    
    func itsLitNoButton() {
        counter += 1
        tapCounter += 1
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if self.tapCounter == 500 {
            JSSAlertView().show(
                self,
                title: "Black Background Unlocked!",
                text: "Hold down the lighter to change background color",
                buttonText: "Right on",
                color: UIColor(r: 254, g: 209, b: 67),
                iconImage: nil)
        }
        
        
        if FIRAuth.auth()?.currentUser?.uid == nil && counter == 20 {
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            
            let alert = UIAlertController(title: "Tip", message: "Sign in to remove Ads", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "It's Lit", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            counter = 0
            stopSpinning()
            createAndLoadInterstitial()
        }
        
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
    
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        // Shake Animation
        navigationController?.navigationBar.shake()
        ItsLitButton.shake()
        worldButton.shake()
        
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
    
    lazy var flameImageView: SpringImageView = {
        let imageView = SpringImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var plusOneText: UILabel = {
        let label = UILabel()
        label.text = "+1"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.isHidden = true
        label.font.withSize(36)
        
        return label
    }()
    
    lazy var plusOneText3: UILabel = {
        let label = UILabel()
        label.text = "+1"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.isHidden = true
        label.font.withSize(36)
        
        return label
    }()
    
    func setupLabel() {
        view.addSubview(plusOneText)
        view.addSubview(plusOneText3)
        
        plusOneText.centerYAnchor.constraint(equalTo: smallItsLitButton.centerYAnchor).isActive = true
        plusOneText.centerXAnchor.constraint(equalTo: smallItsLitButton.centerXAnchor).isActive = true
        plusOneText.widthAnchor.constraint(equalToConstant: 20).isActive = true
        plusOneText.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        plusOneText3.centerYAnchor.constraint(equalTo: smallItsLitButton.centerYAnchor).isActive = true
        plusOneText3.centerXAnchor.constraint(equalTo: smallItsLitButton.centerXAnchor, constant: -30).isActive = true
        plusOneText3.widthAnchor.constraint(equalToConstant: 20).isActive = true
        plusOneText3.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    @IBAction func itsLit(_ sender: UIButton) {
        sendInfo()
        ItsLitButton.shake()
        rotateView()
        counter += 1
        observeFriendsAndSendLitness()
        itsLitImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        itsLitImage.layer.shadowRadius = 10.0
        itsLitImage.layer.shadowColor = UIColor.rgb(254, green: 209, blue: 67).cgColor
        
        //  tapLabel.text = String(tapCounter)
        UIView.animate(withDuration: 0.6, animations: { self.itsLitImage.transform = CGAffineTransform(scaleX: 0.6, y: 0.6) }, completion: { _ in
            UIView.animate(withDuration: 0.6) {
                self.itsLitImage.transform = CGAffineTransform.identity
            }
        })
        
        if self.tapCounter == 25 {
            
        }
        
        if self.tapCounter == 500 {
                let alertView = JSSAlertView().show(
                    self,
                    title: "Background Unlocked!",
                    text: "Hold down the lighter to change the background color to BLACK",
                    buttonText: "It's Lit?",
                    color: .black,
                    iconImage: nil)
            //    alertview.addAction(myCallback) // Method to run after dismissal
                alertView.setTitleFont("AmericanTypewriter-Bold") // Title font
                alertView.setTextFont("AmericanTypewriter") // Alert body text font
                alertView.setButtonFont("AmericanTypewriter-Light") // Button text font
                alertView.setTextTheme(.light)
            }
        
        if self.tapCounter == 1000 {
            let alertView = JSSAlertView().show(
                self,
                title: "OG Flame Unlocked!",
                text: "OG Flame has joined your squad!",
                buttonText: "It's Lit!",
                color: .white,
                iconImage: nil)
            alertView.addAction(animateLighter) // Method to run after dismissal
            alertView.setTitleFont("AmericanTypewriter-Bold") // Title font
            alertView.setTextFont("AmericanTypewriter") // Alert body text font
            alertView.setButtonFont("AmericanTypewriter-Light") // Button text font
        }
        
        if FIRAuth.auth()?.currentUser?.uid == nil && counter == 25 {
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            
            let alert = UIAlertController(title: "Tip", message: "Sign in to remove Ads", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "It's Lit", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            counter = 0
            stopSpinning()
            createAndLoadInterstitial()
        }
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    stopSpinning()
                    itsLitImage.layer.shadowOpacity = 0
                    device?.torchMode = AVCaptureTorchMode.off
                } else {
                    do {
                        if FIRAuth.auth()?.currentUser?.uid != nil {
                        self.tapCounter += 1
                        updateUserTapCounter()
                        }
                        if self.tapCounter > 1000 {
                            animateLighter()
                        }
                        itsLitImage.layer.shadowOpacity = 1
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
    
    func animateLighter() {
      //  layer.animation = "squeezeDown"
      //  layer.animate()
      //  flameImageView.loadGif("Lit Gif")
      //  setupFlames()
      //  flameImageView.animation = "squeezeDown"
      //  flameImageView.animate()
        smallItsLitButton.animation = "morph"
        smallItsLitButton.animateToNext {
            self.smallItsLitButton.animation = "wobble"
            self.smallItsLitButton.animateTo()
        }
        
        UIView.animate(withDuration: 2, animations: {
            self.plusOneText.isHidden = false
            self.plusOneText.shakePoints()
            self.plusOneText.alpha = 1
            
            self.plusOneText3.isHidden = false
            self.plusOneText3.shakePoints3()
            self.plusOneText3.alpha = 1
            self.tapCounter += 1
        })
        
        UIView.animate(withDuration: 1, animations: {
            self.plusOneText.alpha = 0
            self.plusOneText3.alpha = 0
        })
    }
    
    func updateUserTapCounter() {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference().child("User-Score").child(uid)
        var score = self.tapCounter
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let firScore = dictionary["Score"] as? Int
                let currentScore = firScore!
                if currentScore > 0 {
                self.tapCounterLabel.text = String(describing: self.tapCounter)
                score = self.tapCounter
                print (score)
                self.updateScoreLabel(score)
                } else {
                    score = 0
                    let values: [String: AnyObject] = ["Score": score as AnyObject]
                    ref.updateChildValues(values) { (error, ref) in
                        if error != nil {
                            print(error as Any)
                            return
                        }
                    }
                    self.updateScoreLabel(score)
                }
            }
        }, withCancel: nil)
    }
    
    func updateScoreLabel(_ score: Int) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        var newScore = score
        let ref = FIRDatabase.database().reference().child("User-Score").child(uid)
        
        let values: [String: AnyObject] = ["Score": score as AnyObject]
        
        ref.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as Any)
                return
            }
        }

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let firScore = dictionary["Score"] as? Int
                newScore = firScore!
                self.tapCounter = newScore
                self.tapCounterLabel.text = String(newScore)
            }
        }, withCancel: nil)
    }
  
    //MARK: - Peer to Peer connection
    @IBAction func connectScreen(_ sender: AnyObject) {
        self.present(self.browser, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        print (location)
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        map.setUserTrackingMode(.follow, animated: true)
        let uid = (FIRAuth.auth()!.currentUser!.uid)
        //  let ref = FIRDatabase.database().reference()
        let values = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
        
        let locationRef = FIRDatabase.database().reference().child("user-locations").child(uid)
        locationRef.updateChildValues(values) {
            (error, ref) in
            if error != nil {
                print(error as Any)
                return
            }
        }
        
        locationRef.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user-locations").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let locationId = snapshot.key
                let locationsReference = FIRDatabase.database().reference().child("locations").child(locationId)
                locationsReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let locations = Location(dictionary: dictionary)
                        
                        if let locationPartnerId = locations.locationPartnerId() {
                            self.locationsDictionary[locationPartnerId] = locations
                        }
                    }
                    
                }, withCancel: nil)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
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
        if self.session.connectedPeers.count == 1 {
            tapLabel.text = "Connected to: 1 person"
        }else if self.session.connectedPeers.count > 1 {
            let peerCount = String(self.session.connectedPeers.count)
            tapLabel.text = "Connected to: \(peerCount) people"
        } else {
            tapLabel.text = "Connect with others over Wi-Fi"
        }
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
    
    fileprivate func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8446644766706278/1896898949")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)
    }
    
}



