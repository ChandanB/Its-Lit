//
//  LightSwitchActivator.swift
//  Its Lit
//
//  Created by Chandan Brown on 9/18/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit
import AVFoundation

class LightSwitchViewController: UIViewController {
    
    @IBOutlet weak var connectionsLabel: UILabel!
    
    let lightService = LightServiceManager()
    
    func connectedDevicesChanged(_ manager: LightServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation { () -> Void in
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lightService.sendLight()
        lightService.delegate = self as? LightServiceManagerDelegate
    }
    
    @IBAction func itsLit(_ sender: AnyObject) {
        func playSound(_ soundName: String)
        {
            let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "Beacon")!)
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

        self.changeLight()
        lightService.sendLight()
    }
    
    func changeLight() {
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




