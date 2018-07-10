//
//  SoundUtilities.swift
//  Play FootBalll
//
//  Created by John Clute on 6/25/18.
//  Copyright © 2018 creativeApps. All rights reserved.
//

import Foundation
import AVKit

class soundUtilities {
    
    public var buttonPlayer = AVAudioPlayer()
    public var buttonSounds = AVAudioPlayer()
    public var beepSound = AVAudioPlayer()
    

    func setBeepSound(sndIdx: Int) {
        var sndStr = ""
        //   beepSound.stop()
        if (sndIdx == 0) { // First Down
            sndStr = "MEF2"
        } else if (sndIdx == 1) { // Tackle
            sndStr = "MEF3"
        } else if ( sndIdx == 2) { // New Quarter
            sndStr = "MEF4"
        } else if (sndIdx == 3){ // Score
            sndStr = "MEF5"
        }
        
        let audioPath = Bundle.main.path(forResource: sndStr, ofType: "mp3")
        let url = URL(fileURLWithPath: audioPath!)
        
        do {
            try beepSound = AVAudioPlayer(contentsOf: url)
        } catch {
            print ("Beep sound is not set")
            
        }
        
    }
        
    func setClick() {
        let audioPath = Bundle.main.path(forResource: "partnersinrhyme_CLICK17C", ofType: "mp3")
        let url = URL(fileURLWithPath: audioPath!)
        
        do {
            
            try buttonSounds = AVAudioPlayer(contentsOf: url)
            
        } catch {
            
            print("Could not get click audio player to work")
        }
    }
    
    func setBeep() {
        let audioPath = Bundle.main.path(forResource: "partnersinrhyme_BEEP1B", ofType: "mp3")
        let url = URL(fileURLWithPath: audioPath!)
        
        do {
            
            try buttonPlayer = AVAudioPlayer(contentsOf: url)
            
        } catch {
            
            print("Could not get click audio player to work")
        }
    }

}
