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
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate,  UINavigationControllerDelegate , MPMediaPickerControllerDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //MARK: - Objects In View
    
    @IBOutlet weak var smallItsLitButton: SpringImageView!
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
    let user = User()

    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GMSPlacesClient.provideAPIKey("AIzaSyBElxJuZMRg3VIPdRwPr5KwV_SgXMSOfqY")
        GMSServices.provideAPIKey("AIzaSyBElxJuZMRg3VIPdRwPr5KwV_SgXMSOfqY")
        
        itsLitImage.animation = "slideUp"
        itsLitImage.animate()
        
        UINavigationBar.appearance().barTintColor = UIColor.rgb(254, green: 209, blue: 67)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        view.backgroundColor = UIColor.rgb(254, green: 209, blue: 67)
        
        checkIfUserIsLoggedIn()
        
        self.becomeFirstResponder()
        func canBecomeFirstResponder() -> Bool {
            return true
        }
        
        smallItsLitButton.isHidden = true
        smallItsLitButton.isUserInteractionEnabled = true
        
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
            if self.tapCounter < 2 {
                let score = 1
                let values: [String: AnyObject] = ["Score": score as AnyObject]
                let uid = FIRAuth.auth()!.currentUser!.uid
                let ref = FIRDatabase.database().reference().child("User-Score").child(uid)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let firScore = dictionary["Score"] as? Int
                        self.tapCounter = firScore!
                    }
                }, withCancel: nil)

                ref.updateChildValues(values) { (error, ref) in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                }
                self.updateScoreLabel(score)
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
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countForInteraction), userInfo: nil, repeats: true)
            let uid = FIRAuth.auth()!.currentUser!.uid
            let ref = FIRDatabase.database().reference().child("User-Score").child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let firScore = dictionary["Score"] as? Int
                    self.tapCounter = firScore!
                    
                    if self.tapCounter <= 0 {
                        let score = 1
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
            
            view.isUserInteractionEnabled = false

            profileImageView.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled = true
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            
            fetchUserAndSetupNavBarTitle()
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Friends", style: .plain, target: self, action: #selector(goToFriendsPage))
            navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmericanTypewriter", size: 18)!], for: UIControlState.normal)
            navigationItem.rightBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 1)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(connectAlert))
            navigationItem.leftBarButtonItem?.tintColor = UIColor.rgb(51, green: 21, blue: 67)
            navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmericanTypewriter", size: 18)!], for: UIControlState.normal)
        }
    }
    
    func connectAlert() {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "AmericanTypewriter", size: 20)!,
            kTextFont: UIFont(name: "AmericanTypewriter", size: 14)!,
            kButtonFont: UIFont(name: "AmericanTypewriter-Bold", size: 14)!,
            showCloseButton: false
        )
        
        let wifiAlertAppearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "AmericanTypewriter", size: 20)!,
            kTextFont: UIFont(name: "AmericanTypewriter", size: 16)!
        )
        let wifiConnectAlert = SCLAlertView(appearance: wifiAlertAppearance)

        let alertViewIcon = UIImage(named: "people0")
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Connect Over WiFi", backgroundColor: .black, textColor: .white) {
            
            wifiConnectAlert.showWarning("Pro Tip", subTitle: "You need to be on the same WiFi", duration: 5.0, colorStyle: 0xFFFFFF)
            self.connectScreen(self)
        }
        alert.addButton("Connect With Friends", backgroundColor: .black, textColor: .white) {
            self.observeFriendsAndSendLitness(self.user)
        }
        alert.addButton("Location", backgroundColor: .black, textColor: .white) {
            self.showMap(self)
        }
        alert.addButton("No, Solo Dolo", backgroundColor: .red, textColor: .white) {
        }
        alert.showSuccess("Connect", subTitle: "Connect With Others", colorStyle: 0xFFFFFF, circleIconImage: alertViewIcon)
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
                
                self.user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(self.user)
                self.loadPeerToPeer(self.user)
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
    
    func observeFriendsAndSendLitness(_ user: User) {
                let uidName = user.name
                let uid = FIRAuth.auth()!.currentUser!.uid
                let ref = FIRDatabase.database().reference().child("Friend").child(uid)
                let litRef = FIRDatabase.database().reference().child("Litness").child(uidName!)
                //append properties dictionary onto values somehow??
                //key $0, value $1
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        var toId = self.otherUser?.id
                        
                        for snap in snapshots {
                            let allFriends = [snap]
                            print(allFriends)
                            let litId = snap.key
                            toId = litId
                            let friendRef = FIRDatabase.database().reference().child("Friend").child(uid).child(toId!)
                            
                            if let friendSnaps = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                    
                                for snap in friendSnaps {
                            
                                let litId2 = snap.key
                                let litRef2 = litRef.child(toId!)
                                let values: [String: AnyObject] = ["FRIENDS": litId2 as AnyObject]
                                litRef2.updateChildValues(values)
                                }
                            }
                         }
                    }
                }, withCancel: nil)
        
        self.databaseHandleReceiving = litRef.observe(.value, with: { (snapshots) in
                self.itsLitNoButton()
            }, withCancel: nil)
        
    }
    
    //MARK: - Functions
    func showMap(_ sender: Any) {
        setupMap()
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
        self.tapCounter += 1
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        checkForUnlocks()
        
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
        checkForAnimations()

        itsLitImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        itsLitImage.layer.shadowRadius = 10.0
        itsLitImage.layer.shadowColor = UIColor.rgb(254, green: 209, blue: 67).cgColor
        
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
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            startAD()
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
                self.updateScoreLabel(score)
                } else {
                    score = 1
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
        
        checkForUnlocks()
    }
  
    //MARK: - Peer to Peer connection
    @IBAction func connectScreen(_ sender: AnyObject) {
        self.present(self.browser, animated: true, completion: { _ in
            self.browser.navigationController?.delegate = self
            self.browser.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Friends", style: .done, target: self, action: #selector(self.handleLogout))
        })
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
    
    fileprivate func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8446644766706278/1896898949")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)
    }
    
    func startAD() {
        createAndLoadInterstitial()
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
        } else if FIRAuth.auth()?.currentUser?.uid == nil {
            counter += 1
        }

    }
    
    func checkForAnimations() {
        if self.tapCounter > 10 {
            UIView.animate(withDuration: 0.6, animations: { self.itsLitImage.transform = CGAffineTransform(scaleX: 0.6, y: 0.6) }, completion: { _ in
                UIView.animate(withDuration: 0.6) {
                    self.itsLitImage.transform = CGAffineTransform.identity
                }
            })
        }
        if self.tapCounter > 25 {
            ItsLitButton.shake()
        }
        
        if self.tapCounter > 50 {
            rotateView()
        }
    }
    
    func checkForUnlocks() {

        if self.tapCounter == 10  {
            let alertView = JSSAlertView().show(
                self,
                title: "New Animation Unlocked!",
                text: "As you get lit, you'll unlock more cool stuff. 🔥",
                buttonText: "It's Lit",
                color: .black,
                iconImage: nil)
            //    alertview.addAction(myCallback) // Method to run after dismissal
            alertView.setTitleFont("AmericanTypewriter-Bold") // Title font
            alertView.setTextFont("AmericanTypewriter") // Alert body text font
            alertView.setButtonFont("AmericanTypewriter-Light") // Button text font
            alertView.setTextTheme(.light)
            
        }
        
        if self.tapCounter == 25 {
            let alertView = JSSAlertView().show(
                self,
                title: "New Animation Unlocked!",
                text: "IT'S LIT 🔥",
                buttonText: "Okay",
                color: .white,
                iconImage: nil)
            //    alertview.addAction(myCallback) // Method to run after dismissal
            alertView.setTitleFont("AmericanTypewriter-Bold") // Title font
            alertView.setTextFont("AmericanTypewriter") // Alert body text font
            alertView.setButtonFont("AmericanTypewriter-Light") // Button text font
            alertView.setTextTheme(.dark)
        }
        
        if self.tapCounter == 50 {
            let alertView = JSSAlertView().show(
                self,
                title: "SPIN ANIMATION UNLOCKED!",
                text: "WHIP! 🔥",
                buttonText: "It's Lit",
                color: .white,
                iconImage: nil)
            //    alertview.addAction(myCallback) // Method to run after dismissal
            alertView.setTitleFont("AmericanTypewriter-Bold") // Title font
            alertView.setTextFont("AmericanTypewriter") // Alert body text font
            alertView.setButtonFont("AmericanTypewriter-Light") // Button text font
            alertView.setTextTheme(.dark)
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

    }
    
}


struct CurrentUser {
    
}



