//
//  ViewController.swift
//  Play FootBalll
//
//  Created by John Clute on 5/23/18.
//  Copyright © 2018 creativeApps. All rights reserved.
//
/***********************************************************************************************************************
 ElectronicGridIron, formerly Play Football
 Play Football is currently called ElectronicGridIron in the iTunes store, it is a clone of the 1970's,
 Electronic Football Game created by Matel.  This code is not using any code from any other games or products from
 Matel, the only thing it is copying is the Idea, of a single runner and 6 defenders, 3 directional buttons, 1 kick button
 2 Status buttons, and 2 switches, power and program.  Everything else has been figured out by little old me.

 Why, would I do something like this, 2 reasons, first - I wanted to write a game, and I really didn't know anything about
 game design.  And the thought of writing it was daunting.  So instead of a complex video game why not write a game
 when games were simple, Matel football was one of the first hand held games out there, since the iPhone is basically a
 handheld device it seemed to me, a logical choice.  Also the graphics for all practical purposes is quite primative.
 Not to say anything on the iPhone is primative.  Instead of writing a sprite to move around the screen like most
 modern games do, the concept of using a LED, simulated by using UILabels is working out just great. The runner and defense
 move around the field nicely.
 Reason two - Have never been able to beat the game, and since Handheld football games became scarce why not write my own
 and play it.
 
 The code uses 3 classes, ViewController, objectMultiplier, and SoundUtilites.
 ViewController, is the main class for the game, this is were all the controls, logic and displays for the game reside.
 objectMutliplier, contains code to calculate what size a textfield, label, button, and font have to be, in order to be
                   displayed properly on the various iphone sizes.
 SoundUtilities, sounds objects are controlled here, not the play, but what is loaded in the audio class to be played
                 when needed. Later on in development, was having issues with the button click, instead of using the sound utitily
                 Used methods built into the AVfoundating the ios apps when making the keyboard click.  The only methods now
                 being used are whisle sounds used at the of each play.
 
 NOTE: In the future Timer Utilies may be used, this game uses them quite heavily.

 
 ***********************************************************************************************************************/
import UIKit
import AVFoundation
import StoreKit

// MARK: - Customer review requires an optional for a return Integer, added 4 this simplifies how we handle getting intergers from a review.
extension UserDefaults {
    /// Convenience method to wrap the built-in .integer(forKey: ) method in an optional returning nil if the key doesn't exist.
    func integerOptional(forKey: String) -> Int? {
        guard self.object(forKey: forKey) != nil else { return nil }
        return self.integer(forKey: forKey)
    }
    /// Convenience method to wrap the built-in .double(forKey: ) method in an optional returning nil if the key doesn't exist.
    func doubleOptional(forKey: String) -> Double? {
        guard self.object(forKey: forKey) != nil else { return nil }
        return self.double(forKey: forKey)
    }
    /// Convenience method to wrap the built-in .float(forKey: ) method in an optional returning nil if the key doesn't exist.
    func floatOptional(forKey: String) -> Float? {
        guard self.object(forKey: forKey) != nil else { return nil }
        return self.float(forKey: forKey)
    }
    /// Convenience method to wrap the built-in .bool(forKey: ) method in an optional returning nil if the key doesn't exist.
    func boolOptional(forKey: String) -> Bool? {
        guard self.object(forKey: forKey) != nil else { return nil }
        return self.bool(forKey: forKey)
    }
}

/// Football interactions are handled throoughout this ViewController, movement, viewing status, and timers are called or performed in this class.
class ViewController: UIViewController {
    let DEBUG1 = 1
    let DEBUG2 = 2
    let DEBUG3 = 3
    let DEBUG4 = 4
    let DEBUG5 = 5
    var CURRENTLEVEL = 1

    let IPHONE_SE = 320
    let IPHONE_SE_FNT = 16.0
    let tmpIdx = [1, 4, 7, 10, 13, 16, 19, 22,25]
    var tmpI = 0
    var directionForward: Bool = true
    var idx: Int = 1
    var defIdx = [Int]()
    var currentDown: Int = 1
    var fieldPos: Int = 20
    var firstDownMarker: Int = 30
    var toFirstDown: Int = 10
    var visitorScore: Int = 0
    var homeScore: Int = 0
    var scoredFieldGoal: Bool = false
    var defenseStrategy = 2
    var defensePlayCount = 0
    var delayOfGameStarted = false
    var delayOfGameInt = 25
    var firstPlayOfGame: Bool?
    var playInProgress: Bool?
    

    let sizeModifier = objectMultiplierClass()
    var delayOfGameTimer: Timer?
    let QUARTERLIMIT: Int32 = 900
    var defenseTimer : Timer?
    var blinkTimer : Timer?
    var pauseTimer: Timer?
    var gameTimer: Timer?
    var fieldTimer: Timer?
    var countDown: Int32 =  0
    var gameQuarter : Int8 = 1
    var gameTimerStarted: Bool = false
    var isGamePaused : Bool = false
    var madeTackle : Bool = false
    var madeScore : Bool = false
    var dPlayer : Int = 99
    var startOfDowns : Bool = true
    var accessStatButton : Bool = true
    
    var blinkStat : Bool = false
    var canBlink : Bool = false
    var defenseInterval = 2.0
    var startDefenseTimer : Bool = false
    var didAKick: Bool = false
    
    
    // setup soundRoutines
    let sndClass = soundUtilities()
    
    /*
     variables needed by game
     */

    /*
     Outlets, Textfields, labels and buttons
    */
    // Field Position labels
    @IBOutlet var lblFieldPosition: [UILabel]!
    
    
    //Score board
    @IBOutlet weak var countTimerTxtFld: UITextField!
    @IBOutlet weak var downs: UITextField!
    @IBOutlet weak var fldPositon: UITextField!
    @IBOutlet weak var yardsToGo: UITextField!
    @IBOutlet weak var scoreBoard: UIView!
    @IBOutlet weak var lblDown: UILabel!
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblFieldPos: UILabel!
    @IBOutlet weak var lblTimeRemaining: UILabel!
    @IBOutlet weak var lblYTD: UILabel!
    @IBOutlet weak var lblVisitor: UILabel!
    
    // Playing field
    
    // Controller buttons
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var kickButton: UIButton!
    @IBOutlet weak var runRightLeftButton: UIButton!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var powerButton: UISwitch!
    @IBOutlet weak var difficultyButton: UISwitch!
    
    /// Set up app when it first starts.
    /// This method makes sure power is off, controls are disabled and the app is in an off state.
    /// Initial set up is also handled here, playing field is cleared, the Beep sound set for playing.
    /// and reviews are asked at this point.
    override func viewDidLoad() {
        difficultyButton.isEnabled = true
        turnOffControls()
        initialSetup()
        
        
        if ( difficultyButton.isOn ) {
            defenseInterval = 1.0
        } else {
            defenseInterval = 2.0
        }
        sndClass.setBeep()
        
        turnOffScoreBoard()
        askForReview()
}
    
    /// Prompt user for a review, if they have opened the app 10, 25, 50 or 75th time, then we will ask for a review, unless of course
    /// they have already given one, then they wont be asked for one.
    /// hopefully.
    func askForReview () {
        let AppDefaults = UserDefaults.standard
        
        var cnt =  AppDefaults.integerOptional(forKey: "timesUsed")
        if cnt != nil {
            cnt = UserDefaults.standard.integer(forKey: "timesUsed")
            if cnt == 10 {
                SKStoreReviewController.requestReview()
            } else if cnt == 50 {
                SKStoreReviewController.requestReview()
            } else if cnt == 75 {
                SKStoreReviewController.requestReview()
            }
            cnt! += 1
            if cnt! > 101 {
                cnt = 101
            }
            AppDefaults.set(cnt, forKey: "timesUsed")
            
        } else {
            cnt = 1
            AppDefaults.set(cnt, forKey: "timesUsed")
        }
        
    }

    /// Not used
    override func didReceiveMemoryWarning() {
        //      super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // sound routines

    
    
    /// Set up variables to initial values,
    /// Getting size of textfields, labels, this is where we set up point size of fonts, so they will match size of the
    /// phone screen.  We are dynamically sizing the different controls, this way they will look ok.
    ///
    func initialSetup() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In initialSetup")
        }
        
        var fntNewSize: CGFloat
        let y = downs.font?.pointSize
        let y2 = lblDown.font?.pointSize
        let fntSz = sizeModifier.calcTextFieldFont()
        let deviceWidth = UIScreen.main.bounds.maxX
        // see if we are USING a iPHONE SE then subtract 2 from font to fit in text box.
        if (Int(deviceWidth) == IPHONE_SE) {
           fntNewSize = CGFloat(IPHONE_SE_FNT)
        } else { // don't need to reduce the font size by 2, it will fit like normal
            fntNewSize = CGFloat(Int32(CGFloat(fntSz) * y!))
        }
        let newFnt = UIFont(name: downs.font!.fontName, size:  fntNewSize)
        if ( DEBUG3 <= CURRENTLEVEL ) {
            print("Device: \(UIDevice.current.model)")
            print("Device Stats: ]\(UIScreen.main.bounds.maxX) x \(UIScreen.main.bounds.maxY)")
            let newHght = newFnt?.pointSize
            print ("New Font: \(String(describing: newHght))")
        }
        downs.font = newFnt
        fldPositon.font = newFnt
        yardsToGo.font = newFnt
        let lblFntSz  = sizeModifier.calcLabelFont()
        let lblFnt = UIFont(name: lblDown.font.fontName, size: CGFloat(CGFloat(lblFntSz) * y2! ))
        lblDown.font = lblFnt
        lblYTD.font = lblFnt
        lblHome.font = lblFnt
        lblTimeRemaining.font = lblFnt
        lblVisitor.font = lblFnt
        lblVisitor.font = lblFnt
        playInProgress = false
        
        let fldPosFntSz = lblFieldPosition[0].font.pointSize
        let fldFont = sizeModifier.calcTextFieldFont()
        let newFldFont = UIFont(name: lblFieldPosition[0].font.fontName, size: CGFloat(CGFloat(fldFont) * fldPosFntSz))
        if ( DEBUG3 <= CURRENTLEVEL ) {
            print("Count of objects: \(lblFieldPosition.count)")
        }
        for i in 0...(lblFieldPosition.count - 1) {
            if ( DEBUG3 <= CURRENTLEVEL ) {
                print("Count: \(i)")
            }
            lblFieldPosition[i].font = newFldFont
            lblFieldPosition[i].text = ""
        }
    }
    
    /// <#Description#>
    @objc func thirtySecCountDown() {
        if ( DEBUG5 <= CURRENTLEVEL ) {
            print(delayOfGameInt)
        }
        
        delayOfGameInt -= 1
        if ( delayOfGameInt > 0 ) {
            countTimerTxtFld.text = String(delayOfGameInt)
        } else {
            // delay of game penalty
            lightUpField()
            delayOfGameStarted = false
            delayOfGameTimer?.invalidate()
            delayOfGameInt = 25
            countTimerTxtFld.text = "Delay of Game Penalty"
            if (directionForward) {
                if ( fieldPos > 6 ) {
                    fieldPos -= 5
                } else {
                    fieldPos = fieldPos / 2
                }
            } else {
                if ( fieldPos < 96 )  {
                    fieldPos += 5
                } else {
                    let newPos = fieldPos - 95
                    fieldPos = fieldPos + (newPos/2)
                }
            }
            calculateToFirstDown()
        }
        
    }
    
    /*
     Controller Button Actions
    */
    //Status Key
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func statusPressed(_ sender: Any) {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("statusPressed")
        }
        // System sound for button click
        AudioServicesPlaySystemSound(0x450)

        // if we are playing a down, the when the status keys is pressed it
        // should not all the delaytimer to start.
        if ( !playInProgress! ) {
            startDelayTimer()
        }

        if ( accessStatButton ) {
            blinkTimer?.invalidate()
            blinkTimer = nil
            dPlayer = 99
            if ( directionForward ){
                downs.text = "H   "  + String(currentDown)
            } else {
                downs.text = "V   " + String(currentDown)
            }
            
            var outString = ""
            if ( fieldPos < 50 ) {
                outString = "|-   " + String(fieldPos) + "  "
            } else if (fieldPos == 50 ) {
                outString = "  " + String(fieldPos) + "  "
            } else {
                let adjustFldPos = String(100 - fieldPos)
                outString = "  " + adjustFldPos + "   -|"
            }
            
            fldPositon.text = outString
            if (directionForward) {
                yardsToGo.text = String(toFirstDown)
            } else {
                yardsToGo.text = String(toFirstDown)
            }
            clearAllDefense()
            clearField()
        }

    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func statusFinisedPressing(_ sender: Any) {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In statusFinishedPressing")
        }

        if ( accessStatButton) {
            runButtonUpRoutine()
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func scorePressed(_ sender: Any) {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In scorePressed")
        }
        // System sound for button click
        AudioServicesPlaySystemSound(0x450)

        if ( accessStatButton ) {
            blinkTimer?.invalidate()
            dPlayer = 99
            downs.text = String(homeScore)
            let quarter = "Q" + String(gameQuarter) + " - "
            
            let displayGameTime = quarter + String(countDown/60) + ":" + String(format: "%02d",countDown%60)
            fldPositon.text = displayGameTime
            yardsToGo.text = String(visitorScore)
            clearAllDefense()
            clearField()
        }

    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func scoreFinishedPressing(_ sender: Any) {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In scoreFinishedPressing")
        }

        if ( accessStatButton ) {
            runButtonUpRoutine()
        }

    }
    
    /// <#Description#>
    func startDelayTimer () {
        if(DEBUG4 <= CURRENTLEVEL) {
            print("In Start Delay Timer")
        }
        if ( !firstPlayOfGame! ) {
            if ( delayOfGameStarted == false ) {
                delayOfGameStarted = true
                delayOfGameInt = 25
                delayOfGameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(thirtySecCountDown), userInfo: nil, repeats: true)
            }

        }
        
    }
    
    /// <#Description#>
    func stopDelayCountDown() {
        if(DEBUG4 <= CURRENTLEVEL) {
            print("In Stop Delay Timer")
        }
        if ( delayOfGameStarted ) {
            delayOfGameTimer?.invalidate()
            delayOfGameStarted = false
            countTimerTxtFld.text = ""
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func kickPressed(_ sender: Any) {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In kickPressed")
        }
        // System sound for button click
        AudioServicesPlaySystemSound(0x450)

        turnOffControls()
        
        stopDelayCountDown()
        didAKick = true
        if (DEBUG2 <= CURRENTLEVEL) {
            print ("In KickPressed after stopDelayCountDown")
        }
        isGamePaused = false
        pauseGame(gamePaused: isGamePaused)
        isGamePaused = true

        
        let fieldGoalLimit : UInt32 = 55
        if (DEBUG2 <= CURRENTLEVEL) {
            print("Kicking Ball")
        }
        arc4random_stir()
        if (directionForward) {
            showKick()
            if ( fieldPos < 50 ) {
                // we are going to punt
                let upperLimit : UInt32 = UInt32( 100 - fieldPos)
                let randNum = Int(arc4random_uniform(upperLimit) + 15)
                if ( DEBUG3 <= CURRENTLEVEL ) {
                    print("Random Number - \(randNum)")
                }
                let newFldPos = randNum + fieldPos
                if ( (fieldPos + newFldPos ) > 100) {
                    fieldPos = 80
                    firstDownMarker = 90
                    stopPlay()
                } else {
                    fieldPos = newFldPos
                    firstDownMarker = fieldPos + 10 // set first down marker 10 ahead of field pos
                    // stopPlay will read that and treat it as an
                    // unsuccessful run of downs and switch play directions.
                    stopPlay()
                    
                }
            } else {
                // field Goal
                if ( DEBUG2 <= CURRENTLEVEL ) {
                    print("Home Kicking field Goal")
                }
                let randNum = Int(arc4random_uniform(fieldGoalLimit))
                let relativeFieldPos = (100 - fieldPos)
                if ( DEBUG3 <= CURRENTLEVEL ) {
                    print ("Random Number - \(randNum) upperlimite - \(fieldGoalLimit)")
                }
                if ( randNum > (relativeFieldPos)) { // seeing if field goal went farther then field pos
                    // if it did then we have scored.
                    homeScore += 3
                    scoredFieldGoal = true
                    stopPlay()
                    initAllVars()
                } else {
                    stopPlay()
                }
            }
        }  else {
            showKick()
            if ( fieldPos > 50 ) {
                // we are going to punt
                let upperlimit : UInt32 = UInt32(fieldPos) - 15
                let newFldPos = Int(arc4random_uniform(upperlimit))
                if ( (fieldPos + newFldPos ) < 0) {
                    fieldPos = 20
                    firstDownMarker = 10
                    stopPlay()
                } else {
                    fieldPos = newFldPos
                    firstDownMarker = fieldPos - 10 // set first down marker 10 ahead of field pos
                    // stopPlay will read that and treat it as an
                    // unsuccessful run of downs and switch play directions.
                    stopPlay()
                }
            } else {
                // field Goal
                if ( DEBUG2 <= CURRENTLEVEL ) {
                    print("Visitor Kicking FieldGoal")
                }
                let randNum = Int(arc4random_uniform(fieldGoalLimit))
                if ( DEBUG3 <= CURRENTLEVEL ) {
                    print ("Random Number - \(randNum) upperlimite - \(fieldPos)")
                }
                
                if ( randNum > (fieldPos) ) { // determining if kick went farther then
                    // if it did then we have scored a field goal
                    visitorScore += 3
                    scoredFieldGoal = true
                    stopPlay()
                    initAllVars()
                } else {
                    stopPlay()
                }
            }
        }
        if ( DEBUG3 <= CURRENTLEVEL ) {
            print ("Field Position: \(fieldPos) and \(firstDownMarker)")
        }
        playInProgress? = true
    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func runPressed(_ sender: Any) {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In runPressed")
        }
        playInProgress? = true
        // System sound for button click
        AudioServicesPlaySystemSound(0x450);

        stopDelayCountDown()
        kickButton.isEnabled = false

        if ( DEBUG4 <= CURRENTLEVEL ) {
            print("lightUpScreen - Before StartTimer")
        }
        if ( startOfDowns ) {
            if ( directionForward ) {
                moveForward()
            } else {
                moveBack()
            }
            
            startTimer()
            
            madeScore = checkforTouchDown()
            
            madeTackle = runnerTackled()
            
            if (madeScore) {
                if ( DEBUG4 <= CURRENTLEVEL ) {
                    print("Made a touch Down")
                }
                currentDown = 4
                stopPlay()
                initAllVars()
                madeScore = false
            } else if ( madeTackle ) {
                canBlink = true
                stopPlay()
            }
            
        }

    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func upPressed(_ sender: Any) {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In upPressed")
        }
        playInProgress? = true
        // System sound for button click
        AudioServicesPlaySystemSound(0x450);

        stopDelayCountDown()
        kickButton.isEnabled = false

        if ( startOfDowns ) {
            if ( DEBUG2 <= CURRENTLEVEL ) {
                print("upPlayer - before StartTimer")
            }
            
            moveUp()
            startTimer()
            
            madeTackle = runnerTackled()
            if ( madeTackle) {
                stopPlay()
            }
            
        }
        

    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func downPressed(_ sender: Any) {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In DownPressed")
        }

        playInProgress? = true
        // System sound for button click
        AudioServicesPlaySystemSound(0x450)

        stopDelayCountDown()
        kickButton.isEnabled = false

        if ( startOfDowns ) {
            if ( DEBUG2 <= CURRENTLEVEL ) {
                print("downPlayer - before startTimer")
            }
            
            moveDown()
            startTimer()
            
            madeTackle = runnerTackled()
            if ( madeTackle) {
                stopPlay()
            }
        }

        
    }
    
    /// <#Description#>
    func setupNextPlay() {
        /*
         Check for end of quarter sound off new quarter and restart it.
         */
        // setting up defense order for the next play.  The order determines when a deplayer looks for
        // the offensive running back.
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In setupNexPlay")
        }

        defensePlayCount = 0
        arc4random_stir()

        let rndNum = arc4random_uniform(511)
        
        if ( DEBUG3 <= CURRENTLEVEL) {
            print("Random Number: \(rndNum)")
        }
        
        defenseStrategy = 1
        
        if ( (rndNum % 3) == 0 ) {
            if (directionForward){
                defIdx = [25,16,11,10,9]
            } else {
                defIdx = [1,10,17,16,15]
            }
        } else if ( (rndNum % 3 ) == 1 ){
            defenseStrategy = 2
            if ( directionForward ){
                defIdx = [9,10,11,16,25]
            } else {
                defIdx = [15,16,17,10,1]
            }
        } else {
            if ( directionForward ) {
                defIdx = [16,25,9,10,11]
            } else {
                defIdx = [16,15,1,10,17]
            }
        }
        
        startOfDowns = true
        
    }
    
    /// <#Description#>
    @objc func ballMovesForward() {
        clearField()
        setCellImage(lbl: lblFieldPosition[tmpIdx[tmpI]])
        tmpI += 1
        
        if tmpI >= tmpIdx.count {
            turnOnControls()
            pauseTimer?.invalidate()
            pauseTimer = nil
            // we have finished the kick, we can now start the delay timer
            didAKick = false
            startDelayTimer()
            
            if ( scoredFieldGoal ) {
                sndClass.setBeepSound(sndIdx: 3)
                sndClass.beepSound.play()
            }  else {
                sndClass.setBeepSound(sndIdx: 1)
                sndClass.beepSound.play()
            }        }
    }
    
    /// <#Description#>
    @objc func ballMovesBackward() {
        clearField()
        setCellImage(lbl: lblFieldPosition[tmpIdx[tmpI]])
        tmpI -= 1
        
        if tmpI < 0 {
            turnOnControls()
            pauseTimer?.invalidate()
            pauseTimer = nil
            // we are finished the kick we can now start the delaytime after the kick
            didAKick = false
            startDelayTimer()
            
            if ( scoredFieldGoal ) {
                sndClass.setBeepSound(sndIdx: 3)
                sndClass.beepSound.play()
            } else {
                sndClass.setBeepSound(sndIdx: 1)
                sndClass.beepSound.play()
            }
        }
    }
    
    /// <#Description#>
    func showKick() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In showKick")
        }

        let tmpsize = tmpIdx.count
        if ( directionForward ) {
            tmpI = 0
            pauseTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ballMovesForward), userInfo: nil, repeats: true)
        } else {
            tmpI = tmpsize - 1
            pauseTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ballMovesBackward), userInfo: nil, repeats: true)
        }
    }

    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func powerSwitchTouched(_ sender: Any) {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In powerSwitchTouched")
        }
        // System sound for button click
        AudioServicesPlaySystemSound(1104)

        if ( powerButton.isOn == true ) {
            gameStarted()
            startGame()
            firstPlayOfGame = true
        } else {
            gameStopped()
            stopGame()
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func programSwitchTouched(_ sender: Any) {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In programSwitchTouched")
        }
        // System sound for button click
        AudioServicesPlaySystemSound(1104)

        if ( DEBUG5 <= CURRENTLEVEL ) {
            print ("Program button is turned on: \(difficultyButton.isOn)")
        }
        if ( difficultyButton.isOn ) {
            defenseInterval = 1.0
        } else {
            defenseInterval = 2.0
        }
    }
    
    /// <#Description#>
    func runButtonUpRoutine() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In runButtonUpRoutine")
        }

        downs.text = ""
        fldPositon.text = ""
        yardsToGo.text = ""
        clearField()
        if ( directionForward ) {
            idx = 1
        } else {
            idx = 25
        }
        
        setCellImage(lbl: lblFieldPosition[idx])
        setupNextPlay()
        
        displayDefense()
        upButton.isEnabled = true
        downButton.isEnabled = true
        runRightLeftButton.isEnabled = true
        if ( currentDown == 4 ) {
            kickButton.isEnabled = true
        } else {
            kickButton.isEnabled = false
        }
        if ( DEBUG2 <= CURRENTLEVEL ) {
            print("Before isGamePaused in runButtonUpRoutine - \(isGamePaused)")
        }
        
        if ( isGamePaused ) {
            pauseGame(gamePaused: isGamePaused)
            isGamePaused = false
        }
        
        if ( gameQuarter > 4 ) {
            stopGame()
        }
        
        
    }
    
    /// <#Description#>
    func startGame() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In startGame")
        }

        turnOnScoreBoard()
        lightUpField()
        countDown = QUARTERLIMIT
        directionForward = true
        startOfDowns = true
        initAllVars()
        idx = 1
        defIdx = [9,10,11,16,25]
        visitorScore = 0
        homeScore = 0
        downs.text = ""
        fldPositon.text = ""
        yardsToGo.text = ""
        setCellImage(lbl: lblFieldPosition[idx])
        setupNextPlay()
        upButton.isEnabled = true
        downButton.isEnabled = true
        runRightLeftButton.isEnabled = true
        kickButton.isEnabled = false
        statusButton.isEnabled = true
        scoreButton.isEnabled = true
        
        
        gameTimerStarted = false
        visitorScore = 0
        homeScore = 0
        gameQuarter = 1
        fieldPos = 20
        firstDownMarker = 30
        currentDown = 1
        
        clearAllDefense()
        clearField()
        turnOffScoreBoard()
        startGameTimer()
        displayDefense()
        
    }

    /// <#Description#>
    func stopGame () {
        if ( DEBUG4 <= CURRENTLEVEL ) {
            print("in stopGame")
        }
        clearField()
        blinkTimer?.invalidate()
        blinkTimer = nil
        defenseTimer?.invalidate()
        defenseTimer = nil
        gameTimerStarted = true
        startGameTimer()
        
        startOfDowns = false
        upButton.isEnabled = false
        downButton.isEnabled = false
        runRightLeftButton.isEnabled = false
        kickButton.isEnabled = false
        statusButton.isEnabled = false
        scoreButton.isEnabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
        for label in lblFieldPosition {
            label.text = " "
        }
        difficultyButton.isEnabled = true
        powerButton.isOn = false
        
        
    }

    /// <#Description#>
    func moveBack() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In moveBack")
        }

        fieldPos -= 1
        clearCellImage(lbl: lblFieldPosition[idx])
        idx -= 3
        if idx < 0 {
            idx += 27
        }
        
        setCellImage(lbl: lblFieldPosition[idx])
        
    }
    
    /// <#Description#>
    func moveForward() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In moveForward")
        }

        fieldPos += 1
        clearCellImage(lbl: lblFieldPosition[idx])
        idx += 3
        if idx > 26 {
            idx -= 27
        }
        setCellImage(lbl: lblFieldPosition[idx])
    }
    
    /// <#Description#>
    func moveDown() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In moveDown")
        }

        clearCellImage(lbl: lblFieldPosition[idx])
        
        let testIdx = idx - 2
        if ( (testIdx % 3) != 0 ) {
            idx += 1
        }
        
        setCellImage(lbl: lblFieldPosition[idx])
    }
    
    /// <#Description#>
    func moveUp() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In moveUp")
        }

        clearCellImage(lbl: lblFieldPosition[idx])
        
        if ( (idx % 3) != 0) {
            idx -= 1
        }
        setCellImage(lbl: lblFieldPosition[idx])
        
    }

    
    /// <#Description#>
    func turnOnScoreBoard() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In turnOnScoreBoard")
        }

        downs.text = "0"
        fldPositon.text = "0"
        yardsToGo.text = "0"
    }
    /// <#Description#>
    @objc func turnOffScoreBoard() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In turnOffScoreBoard")
        }

        downs.text = ""
        fldPositon.text = ""
        yardsToGo.text = ""
    }
    /// <#Description#>
    func lightUpField() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In lightUpField")
        }

        let sz = lblFieldPosition.count - 1
        for i in 0...sz {
            lblFieldPosition[i].text = "-"
        }
    }
    
    /// <#Description#>
    func initAllVars() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In initaAllVars")
        }

        currentDown = 1
        if (directionForward) {
            fieldPos = 20
            firstDownMarker = fieldPos + 10
        } else {
            fieldPos = 80
            firstDownMarker = fieldPos - 10
        }
    }
    
    /// <#Description#>
    @objc func clearPlayingField() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In clearPlayingField")
        }

        let sz = lblFieldPosition.count - 1
        if ( DEBUG5 <= CURRENTLEVEL ) {
            print("sz = \(sz)")
        }
        for i in 0...sz {
            lblFieldPosition[i].text = ""
            if ( DEBUG5 <= CURRENTLEVEL) {
                print("i = \(i)")
            }
       }
        runButtonUpRoutine()
    }
    
    /// <#Description#>
    ///
    /// - Parameter cellIdx: <#cellIdx description#>
    /// - Returns: <#return value description#>
    func getRowCol(cellIdx: Int) -> [Int]{
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In getRowCol")
        }

        var returnIdx = [99,99]
        let row = cellIdx % 3
        let col = (cellIdx-row) / 3
        returnIdx[0] = row
        returnIdx[1] = col
        return returnIdx
        
    }
    
    /// <#Description#>
    func gameStarted () {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In gameStarted")
        }

        turnOnScoreBoard()
        blinkTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(turnOffScoreBoard), userInfo: nil, repeats: false)
        lightUpField()
        fieldTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(clearPlayingField), userInfo: nil, repeats: false)
        turnOnControls()
    }
    
    /// <#Description#>
    func gameStopped() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In gameStopped")
        }

        turnOffControls()
        stopDelayCountDown()
    }
    
    /// <#Description#>
    func turnOffControls() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In turnOffControls")
        }

        statusButton.isEnabled = false
        scoreButton.isEnabled = false
        runRightLeftButton.isEnabled = false
        upButton.isEnabled = false
        downButton.isEnabled = false
        kickButton.isEnabled = false

    }
    
    /// <#Description#>
    func turnOnControls() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In turnOnControls")
        }

        statusButton.isEnabled = true
        scoreButton.isEnabled = true
        kickButton.isEnabled = true
        runRightLeftButton.isEnabled = true
        upButton.isEnabled = true
        downButton.isEnabled = true

    }
    

    /// <#Description#>
    ///
    /// - Parameter lbl: <#lbl description#>
    func clearCellImage(lbl: UILabel) {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In clearCellImage")
        }

        lbl.text = " "
    }
    

    
    /// <#Description#>
    ///
    /// - Parameter cellIdx: <#cellIdx description#>
    /// - Returns: <#return value description#>
    func canMoveUp(cellIdx : Int) -> [Int] {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In canMoveUp")
        }

        var rcVal = [99,99]
        var dist = 0
        let cmpVal = defIdx[cellIdx] - 1
        for i in 0...4 {
            if ( cellIdx != i) {
                let cmpVal2 = defIdx[i]
                if ( cmpVal == cmpVal2) {
                    return rcVal
                }
            }
        }
        
        let rolCol = getRowCol(cellIdx: cmpVal)
        let offRowCol = getRowCol(cellIdx: idx)
        let pos1 = Int ( abs( rolCol[0] - offRowCol[0]))
        let pos2 = Int ( abs( rolCol[1] - offRowCol[1]))
        
        dist = pos1 + pos2
        rcVal[0] = dist
        rcVal[1] = cmpVal
        return rcVal
    }
    
    /// <#Description#>
    ///
    /// - Parameter cellIdx: <#cellIdx description#>
    /// - Returns: <#return value description#>
    func canMoveDown(cellIdx : Int) -> [Int] {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In canMoveDown")
        }

        var rcVal = [99,99]
        var dist = 0
        let cmpVal = defIdx[cellIdx] + 1
        for i in 0...4 {
            if ( cellIdx != i) {
                let cmpVal2 = defIdx[i]
                if ( cmpVal == cmpVal2) {
                    return rcVal
                }
            }
        }
        
        let rolCol = getRowCol(cellIdx: cmpVal)
        let offRowCol = getRowCol(cellIdx: idx)
        let pos1 = Int ( abs( rolCol[0] - offRowCol[0]))
        let pos2 = Int ( abs( rolCol[1] - offRowCol[1]))
        
        dist = pos1 + pos2
        rcVal[0] = dist
        rcVal[1] = cmpVal
        return rcVal
        
    }
    
    /// <#Description#>
    ///
    /// - Parameter cellIdx: <#cellIdx description#>
    /// - Returns: <#return value description#>
    func canMoveForward(cellIdx : Int) -> [Int] {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In canMoveForward")
        }

        var rcVal = [99,99]
        var dist = 0
        let cmpVal = defIdx[cellIdx] + 3
        for i in 0...4 {
            if ( cellIdx != i) {
                let cmpVal2 = defIdx[i]
                if ( cmpVal == cmpVal2) {
                    return rcVal
                }
            }
        }
        
        let rolCol = getRowCol(cellIdx: cmpVal)
        let offRowCol = getRowCol(cellIdx: idx)
        let pos1 = Int ( abs( rolCol[0] - offRowCol[0]))
        let pos2 = Int ( abs( rolCol[1] - offRowCol[1]))
        
        dist = pos1 + pos2
        rcVal[0] = dist
        rcVal[1] = cmpVal
        return rcVal
        
    }
    
    /// <#Description#>
    ///
    /// - Parameter cellIdx: <#cellIdx description#>
    /// - Returns: <#return value description#>
    func canMoveBack(cellIdx : Int) -> [Int] {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In canMoveBack")
        }

        var rcVal = [99,99]
        var dist = 0
        let cmpVal = defIdx[cellIdx] - 3
        for i in 0...4 {
            if ( cellIdx != i) {
                let cmpVal2 = defIdx[i]
                if ( cmpVal == cmpVal2) {
                    return rcVal
                }
            }
        }
        
        let rolCol = getRowCol(cellIdx: cmpVal)
        let offRowCol = getRowCol(cellIdx: idx)
        let pos1 = Int ( abs( rolCol[0] - offRowCol[0]))
        let pos2 = Int ( abs( rolCol[1] - offRowCol[1]))
        
        dist = pos1 + pos2
        rcVal[0] = dist
        rcVal[1] = cmpVal
        return rcVal
        
    }

    
    /// <#Description#>
    func findClosest() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In findClosest")
        }

        var closestDist = 98
        var cellIdx = 99
        var tmpArr = [Int]()
        var newId = 8
        
        for i in 0...4 {
            let cellVal = defIdx[i]
            let pos = getRowCol(cellIdx: cellVal)
            let row = pos[0]
            let col = pos[1]
            if ( row != 0 ) {
                tmpArr = canMoveUp(cellIdx: i)
                if ( tmpArr[0] < closestDist ) {
                    closestDist = tmpArr[0]
                    cellIdx = tmpArr[1]
                    newId = i
                }
            }
            if ( row != 2 ) {
                tmpArr = canMoveDown(cellIdx: i)
                if ( tmpArr[0] < closestDist ) {
                    closestDist = tmpArr[0]
                    cellIdx = tmpArr[1]
                    newId = i
                }
                
            }
            if ( col != 0 ) {
                tmpArr = canMoveBack(cellIdx: i)
                if ( tmpArr[0] < closestDist ) {
                    closestDist = tmpArr[0]
                    cellIdx = tmpArr[1]
                    newId = i
                }
            }
            if ( col != 8 ) {
                tmpArr = canMoveForward(cellIdx: i)
                if ( tmpArr[0] < closestDist ) {
                    closestDist = tmpArr[0]
                    cellIdx = tmpArr[1]
                    newId = i
                }
                
            }
        }
        
        defIdx[newId] = cellIdx
        
        
    }
    
    /// <#Description#>
    func clearField() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In clearField")
        }

        for i in 0...lblFieldPosition.count - 1 {
            lblFieldPosition[i].text = " "
        }
    }
    
    /// <#Description#>
    func clearAllDefense() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In clearAllDefense")
        }

        for i in defIdx {
            clearCellImage(lbl: lblFieldPosition[i])
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameter defense: <#defense description#>
    func startBlink(defense: Int) {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In startBlink")
        }

        if ( canBlink ) {
            dPlayer = defense
            blinkTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(blinkCell), userInfo: nil, repeats: true)
            canBlink = false
        }
    }
    
    /// <#Description#>
    @objc func blinkCell() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In blinkCell")
        }

        if ( blinkStat) {
            setRegCell(lbl: lblFieldPosition[dPlayer])
            blinkStat = false
        } else {
            clearCellImage(lbl: lblFieldPosition[dPlayer])
            blinkStat = true
        }
    }
    /// <#Description#>
    ///
    /// - Parameter lbl: <#lbl description#>
    func setRegCell( lbl: UILabel) {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In setRegCell")
        }

        lbl.font = UIFont(name: "Din Condensed", size: 24.0)
        lbl.text = "-"
        lbl.textColor = UIColor.red
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter lbl: <#lbl description#>
    func setCellImage(lbl: UILabel) {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In setCellImage")
        }

        
        lbl.font = UIFont(name: "Din Alternate", size: 32.0)
        
        lbl.text = "-"
        lbl.textColor = UIColor.orange
        
    }
    
    /// <#Description#>
    func moveDefenseForward() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In moveDefeseForward")
        }

        /*
         Look to see if defense cam move forward, if there is another defensive player in cell,
         Dont' move forward, instead, get a new player and see if they can move forward then move forward.
        */
        defensePlayCount += 1
        var defenseSpaceOccupied = true
        while (defenseSpaceOccupied) {
            let rndPlay = Int(arc4random_uniform(4))
            if ( defensePlayCount < 4 ) {
                if (directionForward == true) {
                    let arTmp = canMoveBack(cellIdx: rndPlay)
                    if ( arTmp[0] < 99  ) {
                        defIdx[rndPlay] = arTmp[1]
                        defenseSpaceOccupied = false
                    }
                } else {
                    let arTmp = canMoveForward(cellIdx: rndPlay)
                    if ( arTmp[0] < 99 ) {
                        defIdx[rndPlay] = arTmp[1]
                        defenseSpaceOccupied = false
                    }
                }
            } else {
                findClosest()
                defenseSpaceOccupied = false
            }
            
        }
        
    }

    /// <#Description#>
    @objc func moveDefense() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In moveDefense")
        }

        // work on new algorythm to move the defense
        //  print ("Interval - \(defenseInterval)")
        clearAllDefense()
        if ( defenseStrategy == 1 ) {
            findClosest()
        } else {
            moveDefenseForward()
        }
        displayDefense()
        madeTackle = runnerTackled()
        if ( madeTackle) {
            stopPlay()
        }
    }
    
    /// <#Description#>
    func displayDefense() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In displayDefense")
        }

        for i in defIdx {
            setRegCell(lbl: lblFieldPosition[i])
        }
    }
    
    /// <#Description#>
    func startGameTimer () {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In startGameTimer")
        }

        if ( DEBUG2 <= CURRENTLEVEL ) {
            print("in start Game Timer")
        }
        if ( gameTimerStarted == false) {
            gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decrementGameTime), userInfo: nil, repeats: true)
            gameTimerStarted = true
        } else {
            gameTimer?.invalidate()
            gameTimer = nil
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameter gamePaused: <#gamePaused description#>
    func pauseGame( gamePaused: Bool) {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In pauseGame")
        }

        if ( DEBUG4 <= CURRENTLEVEL ) {
            print( "in Pause Game" )
        }
        if ( gamePaused == true ) {
            gameTimerStarted = false
            startGameTimer()
        } else {
            gameTimer?.invalidate()
        }
    }
    
    /// <#Description#>
    @objc func decrementGameTime() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In decrementGameTimer")
        }

        if ( DEBUG4 <= CURRENTLEVEL ) {
            print("in decrement game timer")
        }
        countDown -= 1
        if ( countDown <= 0 ) {
            isGamePaused = false
            pauseGame(gamePaused: isGamePaused )
            isGamePaused = true
            countDown = QUARTERLIMIT
            gameQuarter += 1
            
            if ( gameQuarter == 3 )  {  // Starting second half switch sides
                directionForward = false
                initAllVars()
                currentDown = 1
                
            }
            
            if ( gameQuarter > 4 ) {
                stopPlay()
                lightUpField()
            }
        }
    }


    /// <#Description#>
    func startTimer() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In startTimer")
        }

        if (  startDefenseTimer  == false ) {
            // we are going to disable the status buttons here.  This is pretty much when the play starts
            // and we can control when it will happen
            accessStatButton = false
            if ( DEBUG4 <= CURRENTLEVEL ) {
                print("Starting Defense Timer")
            }
            startDefenseTimer = true
            defenseTimer = Timer.scheduledTimer(timeInterval: defenseInterval, target: self, selector: #selector(moveDefense), userInfo: nil, repeats: true)
            moveDefense()
        }
        
    }
    
    /// <#Description#>
    func stoptimer() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In stopTimer")
        }

        if ( defenseTimer != nil ) {
            defenseTimer?.invalidate()
            if (defenseTimer?.isValid)! {
                print("Could not stop Timer!")
            }
        }
        if ( DEBUG3 <= CURRENTLEVEL ) {
            print("Stopping defense timer")
        }
    }
    
    /// <#Description#>
    func calculateToFirstDown () {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In calculateToFirstDown")
        }

        if ( directionForward) {
            toFirstDown = firstDownMarker - fieldPos
        } else {
            toFirstDown = fieldPos - firstDownMarker
        }
    }
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func runnerTackled() ->  Bool {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In runnerTackled")
        }

        var i = 0
        var defPos: Int = 99
        while i < defIdx.count {
            defPos = defIdx[i]
            if ( defPos == idx ) {
                startBlink(defense: defPos)
                sndClass.setBeepSound(sndIdx: 1)
                sndClass.beepSound.play()
                return true
            }
            i += 1
        }
        return false
    }
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func checkforTouchDown() -> Bool {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In checkforTouchDown")
        }

        var rcBool = false
        if (directionForward) {
            if (fieldPos >= 100 ) {
                homeScore += 7
                rcBool = true
            }
        } else {
            if (fieldPos <= 0 ) {
                visitorScore += 7
                rcBool = true
            }
        }
        if ( rcBool == true ) {
            sndClass.setBeepSound(sndIdx: 3)
            sndClass.beepSound.play()
        }
        return rcBool
    }
    
    /// <#Description#>
    func setPlayDirection() {
        if (DEBUG4 <= CURRENTLEVEL) {
            print("In setplayerDirection")
        }

        if (directionForward ) {
            directionForward = false
        } else {
            directionForward = true
        }
        if ( DEBUG3 <= CURRENTLEVEL ) {
            print("Setting playDirection to \(directionForward)")
        }
        
    }
    
    /// <#Description#>
    func endOfPlayIncrements() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In endOfPlayIncrements")
        }

        if ( firstPlayOfGame! ) {
            firstPlayOfGame? = false
        }
        
        startDefenseTimer = false
        
        if ( DEBUG3 <= CURRENTLEVEL ) {
            print("Before - Current Down:\(currentDown)")
        }
        
        /*
         Check to see how far the offense traveled, if it is greater then 10 yards
         we get a first down, if not then change nothing other then what was changed
         with downs.
         if the Home player is running, subract field pos from firstdown marker this will give us
         what yards where traveled.
         if visitor, then subract firstdown from field pos, this is taking in account the that we
         are decrementing the field pos.
         */
        
        if ( madeScore ) {
            isGamePaused = false
            pauseGame(gamePaused: isGamePaused)
            isGamePaused = true
            setPlayDirection()
            if ( directionForward ) {
                fieldPos = 20
                firstDownMarker = fieldPos + 10
            } else {
                fieldPos = 80
                firstDownMarker = fieldPos - 10
            }
            calculateToFirstDown()
            
        } else {
            calculateToFirstDown()
            // Start delay of game timer, at the end of play.
            // instead of waiting for somebody to start where they can still
            // sit on the clock and win he game by just cheating when they are ahead and
            // not playing for the rest of the game.
            if (DEBUG3 <= CURRENTLEVEL) {
                print("after calculateToFirstDown")
            }

            if (!didAKick) {
                startDelayTimer()
            }
            
            if ( toFirstDown <= 0) {
                if ( DEBUG3 <= CURRENTLEVEL ) {
                    print("We have a first Down! \(toFirstDown)")
                }
                sndClass.setBeepSound(sndIdx: 0)
                sndClass.beepSound.play()
                if (directionForward) {
                    firstDownMarker = fieldPos + 10
                    if (firstDownMarker > 100) {
                        firstDownMarker = 100
                    }
                } else {
                    firstDownMarker = fieldPos - 10
                    if ( firstDownMarker < 0 ) {
                        firstDownMarker = 0
                    }
                }
                currentDown = 1
                calculateToFirstDown()
            } else {
                // check to see if we are at the end of the series of downs
                // and we didn't get a first down then we hand the ball
                // to the opposing team.
                if (currentDown == 4) {
                    currentDown = 1
                    firstDownMarker = fieldPos
                    toFirstDown = 10
                    setPlayDirection()
                    if (directionForward) { // setting firstdown to reflex new play direction
                        firstDownMarker += 10
                        if (firstDownMarker > 100) {
                            if ( DEBUG3 <= CURRENTLEVEL ) {
                                print("Setting firstdown marker to 100")
                            }
                            firstDownMarker = 100
                        }
                    } else {
                        firstDownMarker -= 10
                        if ( firstDownMarker < 0 ) {
                            if ( DEBUG3 <= CURRENTLEVEL ) {
                                print("Setting first Down maker to 0")
                            }
                            firstDownMarker =  0
                        }
                    }
                } else {
                    // increment current down
                    currentDown += 1
                    if ( DEBUG3 <= CURRENTLEVEL ) {
                        print("Current Down:\(currentDown)")
                    }
                }
                
            }
        }
    }
    
    /// <#Description#>
    func stopPlay() {
        if (DEBUG5 <= CURRENTLEVEL) {
            print("In stopPlay")
        }

        // set play progress flag to false, this allows the delay timer to start in status.
        playInProgress = false
        
        // play is over, now we can allow access to the status buttons
        accessStatButton = true
        startOfDowns = false
        if ( DEBUG3 <= CURRENTLEVEL ) {
            print("\(runRightLeftButton.state.rawValue)")
            print("Stopping play")
        }
        upButton.isEnabled = false
        downButton.isEnabled = false
        runRightLeftButton.isEnabled = false
        stoptimer()
        endOfPlayIncrements()
    }
}

