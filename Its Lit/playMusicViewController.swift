//
//  playMusicViewController.swift
//  Its Lit
//
//  Created by Chandan Brown on 12/2/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class playMusicViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var peopleButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    var mediaPicker: MPMediaPickerController?
    var myMusicPlayer: MPMusicPlayerController?
    let masterVolumeSlider: MPVolumeView = MPVolumeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        volumeSlider.tintColor = UIColor.rgb(223, green: 39, blue: 48)
        let origImage = UIImage(named: "people")
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        peopleButton.setImage(tintedImage, for: .normal)
        peopleButton.tintColor = UIColor.rgb(223, green: 39, blue: 48)
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var musicSelector: UIButton!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func mediaPicker(mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection){
        
        self.myMusicPlayer = MPMusicPlayerController()
        myMusicPlayer?.beginGeneratingPlaybackNotifications()
        myMusicPlayer?.setQueue(with: mediaItemCollection)
        myMusicPlayer?.play()
        MusicHelper.sharedHelper.playBackgroundMusic()
        self.updateNowPlayingItem()
        dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func displayMediaPickerAndPlayItem(){
        
        mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        
        if let picker = mediaPicker {
            
            print("Successfully instantiated a media picker")
            picker.delegate = self
            picker.showsCloudItems = true
            picker.prompt = "Pick a song"
            view.addSubview(picker.view)
            present(picker, animated: true, completion: nil)
            
        } else {
            print("Could not instantiate a media picker")
        }
    }
    
    func nowPlayingItemIsChanged(notification: NSNotification){
        
        print("Playing Item Is Changed")
        
        let key = "MPMusicPlayerControllerNowPlayingItemPersistentIDKey"
        
        let persistentID =
            notification.userInfo![key] as? NSString
        
        if let id = persistentID{
            print("Persistent ID = \(id)")
        }
        
    }
    
    func volumeIsChanged(notification: NSNotification){
        print("Volume Is Changed")
    }
    
    func updateNowPlayingItem(){
        if let nowPlayingItem=self.myMusicPlayer!.nowPlayingItem{
            let nowPlayingTitle=nowPlayingItem.title
            self.nowPlayingLabel.text=nowPlayingTitle
        }else{
            self.nowPlayingLabel.text="Nothing Played"
        }
    }

    @IBAction func openItunesLibraryTapped(_ sender: Any) {
        displayMediaPickerAndPlayItem()
    }
    
    @IBAction func sliderVolume(_ sender: Any) {
        if let view = masterVolumeSlider.subviews.first as? UISlider{
            view.value = (sender as AnyObject).value
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
