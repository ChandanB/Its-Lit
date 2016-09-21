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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var profileImageView: UIView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Its Lit")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        imageView.clipsToBounds = true
        
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
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
    func setupProfileImageView(_ view: UIView) {
        

        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
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
    
    func itsLit(_ sender: UIButton) {
        
        func playSound(_ soundName: String)
        {
            let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "aiff")!)
            do{
                let audioPlayer = try AVAudioPlayer(contentsOf:alertSound)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            }catch {
                print("Error getting the audio file")
            }
        }
        
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
    
}

