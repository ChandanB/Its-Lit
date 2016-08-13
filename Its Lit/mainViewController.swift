//
//  mainViewController.swift
//  Its Lit
//
//  Created by Chandan Brown on 8/12/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import UIKit
import AVFoundation

class mainViewController: UIViewController {
    
    var itsLitImage: UIImageView!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    lazy var profileImageView: UIView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Its Lit")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill

        imageView.clipsToBounds = true
        
        imageView.userInteractionEnabled = true
        
        return imageView
    }()
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerate() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.rgb(90, green: 151, blue: 213)
        navigationController?.navigationBar.tintColor = UIColor.rgb(90, green: 151, blue: 213)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.rgb(90, green: 151, blue: 213)]

        
       // view.backgroundColor = UIColor.rgb(254, green: 209, blue: 67)
        
        view.addSubview(profileImageView)
        
        setupProfileImageView(profileImageView)
        
        func canBecomeFirstResponder() -> Bool {
            return true
        }
        
    }
    func setupProfileImageView(view: UIView) {
        

        
        profileImageView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(400).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(400).active = true
        
        
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            if (device.hasTorch) {
                do {
                    try device.lockForConfiguration()
                    if (device.torchMode == AVCaptureTorchMode.On) {
                        device.torchMode = AVCaptureTorchMode.Off
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                    } else {
                        do {
                            try device.setTorchModeOnWithLevel(1.0)
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        } catch {
                            print(error)
                        }
                    }
                    device.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
            
        }
    }
    
    func itsLit(sender: UIButton) {
        
        func playSound(soundName: String)
        {
            let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(soundName, ofType: "aiff")!)
            do{
                let audioPlayer = try AVAudioPlayer(contentsOfURL:alertSound)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }catch {
                print("Error getting the audio file")
            }
        }
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    do {
                        try device.setTorchModeOnWithLevel(1.0)
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        
    }
    
}

