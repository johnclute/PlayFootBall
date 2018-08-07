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
    /*********************
     Class:  soundUtilities
     Purpose: Collection of methods that play specific sounds for the football Game.
     Methods:
            setBeepSound
            setClick
            setBeep
     Variables:
        buttonPlayer:  play sounds for directional keys - not used
        buttonSounds:  plays the clicking sounds when a key is pressed -  not used
        beepSound:  Sounds used by game when play is over, user calls sounds by beepSound.play()
    **********************/
    
    public var buttonPlayer = AVAudioPlayer()
    public var buttonSounds = AVAudioPlayer()
    public var beepSound = AVAudioPlayer()
    

    /// set one of 4 sounds for end of game play.
    ///  if sndIdx:
    ///    0 - trill sound - first down
    ///    1 - 2 whistles sounds - tackle
    ///    2 - buzzer - new Quarter
    ///    3 - Charge sound - Score
    /// attaches the sound to beepSound, when beepsound is played it will play the selected sound.
    ///
    /// - Parameter sndIdx: Index for sound that is going to be played
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
        
    /// Depreciated
    /// Sets the clicking sound used by the keys when they are pressed, this affected, Status button,
    /// Score button and Kick Button
    /// set buttonSounds so that it can be played when called.
    func setClick() {
        let audioPath = Bundle.main.path(forResource: "partnersinrhyme_CLICK17C", ofType: "mp3")
        let url = URL(fileURLWithPath: audioPath!)
        
        do {
            
            try buttonSounds = AVAudioPlayer(contentsOf: url)
            
        } catch {
            
            print("Could not get click audio player to work")
        }
    }
    
    /// Depreciated:
    /// Sets beep sound to buttonPlayer, the audio class for playing sounds when the directional keys are pressed.
    ///
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
