//
//  musicHelper.swift
//  Its Lit
//
//  Created by Chandan Brown on 12/2/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import AVFoundation

class MusicHelper {
    static let sharedHelper = MusicHelper()
    var audioPlayer: AVAudioPlayer?
    
    func playBackgroundMusic() {
        let pickedSong = NSURL(fileURLWithPath: Bundle.main.path(forResource: "userPickedSong", ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: pickedSong as URL)
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch {
            print("Cannot play the file")
        }
    }
}
