//
//  ViewController.swift
//  Play FootBalll
//
//  Created by John Clute on 5/23/18.
//  Copyright © 2018 creativeApps. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
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

    let sizeModifier = objectMultiplierClass()
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

    let DEBUG = 4
    
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
    
    override func viewDidLoad() {
        difficultyButton.isEnabled = true
        turnOffControls()
        initialSetup()
        
        if ( difficultyButton.isOn ) {
            defenseInterval = 1.0
        } else {
            defenseInterval = 2.0
        }
        sndClass.setClick()
        sndClass.setTurnOnSound()
}
    
    override func didReceiveMemoryWarning() {
        //      super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // sound routines

    
    
    func initialSetup() {
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
        if ( DEBUG > 3 ) {
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
        
        let fldPosFntSz = lblFieldPosition[0].font.pointSize
        let fldFont = sizeModifier.calcTextFieldFont()
        let newFldFont = UIFont(name: lblFieldPosition[0].font.fontName, size: CGFloat(CGFloat(fldFont) * fldPosFntSz))
        print("Count of objects: \(lblFieldPosition.count)")
        for i in 0...(lblFieldPosition.count - 1) {
            if ( DEBUG < 4 ) {
                print("Count: \(i)")
            }
            lblFieldPosition[i].font = newFldFont
            lblFieldPosition[i].text = ""
        }
    }
    
    /*
     Controller Button Actions
    */
    //Status Key
    @IBAction func statusPressed(_ sender: Any) {
        
    //    sndClass.buttonPlayer.stop()
        sndClass.buttonPlayer.play()
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
    
    @IBAction func statusFinisedPressing(_ sender: Any) {
        if ( accessStatButton) {
            runButtonUpRoutine()
        }
    }
    
    @IBAction func scorePressed(_ sender: Any) {
   //     sndClass.buttonPlayer.stop()
        sndClass.buttonPlayer.play()
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
    
    @IBAction func scoreFinishedPressing(_ sender: Any) {
        if ( accessStatButton ) {
            runButtonUpRoutine()
        }

    }
    
    @IBAction func kickPressed(_ sender: Any) {
        
        isGamePaused = false
        pauseGame(gamePaused: isGamePaused)
        isGamePaused = true
        sndClass.buttonPlayer.stop()
        sndClass.buttonPlayer.play()
        let fieldGoalLimit : UInt32 = 55
        if (DEBUG > 3) {
            print("Kicking Ball")
        }
        arc4random_stir()
        if (directionForward) {
            showKick()
            if ( fieldPos < 50 ) {
                // we are going to punt
                let upperLimit : UInt32 = UInt32( 100 - fieldPos)
                let randNum = Int(arc4random_uniform(upperLimit) + 15)
                if ( DEBUG > 3 ) {
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
                if ( DEBUG > 3 ) {
                    print("Home Kicking field Goal")
                }
                let randNum = Int(arc4random_uniform(fieldGoalLimit))
                let relativeFieldPos = (100 - fieldPos)
                if ( DEBUG > 3 ) {
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
                if ( DEBUG > 3 ) {
                    print("Visitor Kicking FieldGoal")
                }
                let randNum = Int(arc4random_uniform(fieldGoalLimit))
                if ( DEBUG > 3 ) {
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
        if ( DEBUG > 3 ) {
            print ("Field Position: \(fieldPos) and \(firstDownMarker)")
        }

    }
    
    @IBAction func runPressed(_ sender: Any) {
//        sndClass.buttonPlayer.stop()
        sndClass.buttonPlayer.play()
        if ( DEBUG > 3 ) {
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
                if ( DEBUG > 3 ) {
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
    
    @IBAction func upPressed(_ sender: Any) {
 //      sndClass.buttonPlayer.stop()
        sndClass.buttonPlayer.play()
        if ( startOfDowns ) {
            if ( DEBUG > 3 ) {
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
    
    @IBAction func downPressed(_ sender: Any) {
   //     sndClass.buttonPlayer.stop()
          sndClass.buttonPlayer.play()
        if ( startOfDowns ) {
            if ( DEBUG > 3 ) {
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
    func setupNextPlay() {
        /*
         Check for end of quarter sound off new quarter and restart it.
         */
        // setting up defense order for the next play.  The order determines when a deplayer looks for
        // the offensive running back.
        
        arc4random_stir()
        let rndNum = arc4random_uniform(511)
        
        if ( DEBUG > 3) {
            print("Random Number: \(rndNum)")
        }
        
        if (directionForward) {
            if ( (rndNum % 3) == 0 ) {
                defIdx = [25,16,11,10,9]
            } else if ( (rndNum % 3 ) == 1 ){
                defIdx = [9,10,11,16,25]
            } else {
                defIdx = [16,25,9,10,11]
            }
        } else {
            if ( (rndNum % 3) == 0 ) {
                defIdx = [1,10,17,16,15]
            } else if ( (rndNum % 3 ) == 1 ) {
                defIdx = [15,16,17,10,1]
            } else  {
                defIdx = [16,15,1,10,17]
            }
        }
        startOfDowns = true
        
    }
    
    @objc func nothing() {
        clearField()
        setCellImage(lbl: lblFieldPosition[tmpIdx[tmpI]])
        tmpI += 1
        
        if tmpI >= tmpIdx.count {
            pauseTimer?.invalidate()
            pauseTimer = nil
            if ( scoredFieldGoal ) {
                sndClass.setBeepSound(sndIdx: 3)
                sndClass.beepSound.play()
            }
        }
    }
    
    @objc func nothing2() {
        clearField()
        setCellImage(lbl: lblFieldPosition[tmpIdx[tmpI]])
        tmpI -= 1
        
        if tmpI < 0 {
            pauseTimer?.invalidate()
            pauseTimer = nil
            if ( scoredFieldGoal ) {
                sndClass.setBeepSound(sndIdx: 3)
                sndClass.beepSound.play()
            }
        }
    }
    
    func showKick() {
        let tmpsize = tmpIdx.count
        if ( directionForward ) {
            tmpI = 0
            pauseTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(nothing), userInfo: nil, repeats: true)
        } else {
            tmpI = tmpsize - 1
            pauseTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(nothing2), userInfo: nil, repeats: true)
        }
    }

    @IBAction func powerSwitchTouched(_ sender: Any) {
        if ( powerButton.isOn == true ) {
            gameStarted()
            startGame()
        } else {
           gameStopped()
            stopGame()
        }
    }
    
    @IBAction func programSwitchTouched(_ sender: Any) {
     //   sndClass.buttonPlayer.stop()
        sndClass.buttonPlayer.play()
        if ( DEBUG > 3 ) {
            print ("Program button is turned on: \(difficultyButton.isOn)")
        }
        if ( difficultyButton.isOn ) {
            defenseInterval = 1.0
        } else {
            defenseInterval = 2.0
        }
    }
    
    func runButtonUpRoutine() {
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
        if ( DEBUG > 3 ) {
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
    func startGame() {
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
        clearAllDefense()
        clearField()
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

        startGameTimer()
        displayDefense()
        
    }

    func stopGame () {
        if ( DEBUG > 3 ) {
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

    func moveBack() {
        fieldPos -= 1
        clearCellImage(lbl: lblFieldPosition[idx])
        idx -= 3
        if idx < 0 {
            idx += 27
        }
        
        setCellImage(lbl: lblFieldPosition[idx])
        
    }
    
    func moveForward() {
        fieldPos += 1
        clearCellImage(lbl: lblFieldPosition[idx])
        idx += 3
        if idx > 26 {
            idx -= 27
        }
        setCellImage(lbl: lblFieldPosition[idx])
    }
    
    func moveDown() {
        clearCellImage(lbl: lblFieldPosition[idx])
        
        let testIdx = idx - 2
        if ( (testIdx % 3) != 0 ) {
            idx += 1
        }
        
        setCellImage(lbl: lblFieldPosition[idx])
    }
    
    func moveUp() {
        clearCellImage(lbl: lblFieldPosition[idx])
        
        if ( (idx % 3) != 0) {
            idx -= 1
        }
        setCellImage(lbl: lblFieldPosition[idx])
        
    }

    
    func turnOnScoreBoard() {
        downs.text = "0"
        fldPositon.text = "0"
        yardsToGo.text = "0"
    }
    @objc func turnOffScoreBoard() {
        downs.text = ""
        fldPositon.text = ""
        yardsToGo.text = ""
    }
    func lightUpField() {
        let sz = lblFieldPosition.count - 1
        for i in 0...sz {
            lblFieldPosition[i].text = "-"
        }
    }
    
    func initAllVars() {
        currentDown = 1
        if (directionForward) {
            fieldPos = 20
            firstDownMarker = fieldPos + 10
        } else {
            fieldPos = 80
            firstDownMarker = fieldPos - 10
        }
    }
    
    @objc func clearPlayingField() {
        let sz = lblFieldPosition.count - 1
        print("sz = \(sz)")
        for i in 0...sz {
            lblFieldPosition[i].text = ""
           print("i = \(i)")
       }
        runButtonUpRoutine()
    }
    
    func getRowCol(cellIdx: Int) -> [Int]{
        var returnIdx = [99,99]
        let row = cellIdx % 3
        let col = (cellIdx-row) / 3
        returnIdx[0] = row
        returnIdx[1] = col
        return returnIdx
        
    }
    
    func gameStarted () {
        turnOnScoreBoard()
        blinkTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(turnOffScoreBoard), userInfo: nil, repeats: false)
        lightUpField()
        fieldTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(clearPlayingField), userInfo: nil, repeats: false)
        turnOnControls()
    }
    
    func gameStopped() {
        turnOffControls()
    }
    
    func turnOffControls() {
        statusButton.isEnabled = false
        scoreButton.isEnabled = false
        runRightLeftButton.isEnabled = false
        upButton.isEnabled = false
        downButton.isEnabled = false
        kickButton.isEnabled = false

    }
    
    func turnOnControls() {
        statusButton.isEnabled = true
        scoreButton.isEnabled = true
        kickButton.isEnabled = true
        runRightLeftButton.isEnabled = true
        upButton.isEnabled = true
        downButton.isEnabled = true

    }
    

    func clearCellImage(lbl: UILabel) {
        lbl.text = " "
    }
    

    
    func canMoveUp(cellIdx : Int) -> [Int] {
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
    
    func canMoveDown(cellIdx : Int) -> [Int] {
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
    
    func canMoveForward(cellIdx : Int) -> [Int] {
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
    
    func canMoveBack(cellIdx : Int) -> [Int] {
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

    
    func findClosest() {
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
    func clearField() {
        for i in 0...lblFieldPosition.count - 1 {
            lblFieldPosition[i].text = " "
        }
    }
    
    func clearAllDefense() {
        for i in defIdx {
            clearCellImage(lbl: lblFieldPosition[i])
        }
    }
    
    func startBlink(defense: Int) {
        if ( canBlink ) {
            dPlayer = defense
            blinkTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(blinkCell), userInfo: nil, repeats: true)
            canBlink = false
        }
    }
    
    @objc func blinkCell() {
        if ( blinkStat) {
            setRegCell(lbl: lblFieldPosition[dPlayer])
            blinkStat = false
        } else {
            clearCellImage(lbl: lblFieldPosition[dPlayer])
            blinkStat = true
        }
    }
    func setRegCell( lbl: UILabel) {
        lbl.font = UIFont(name: "Din Condensed", size: 24.0)
        lbl.text = "-"
        lbl.textColor = UIColor.red
    }
    
    
    func setCellImage(lbl: UILabel) {
        
        lbl.font = UIFont(name: "Din Alternate", size: 32.0)
        
        lbl.text = "-"
        lbl.textColor = UIColor.red
        
    }

    @objc func moveDefense() {
        // work on new algorythm to move the defense
        //  print ("Interval - \(defenseInterval)")
        clearAllDefense()
        findClosest()
        displayDefense()
        madeTackle = runnerTackled()
        if ( madeTackle) {
            stopPlay()
        }
    }
    
    func displayDefense() {
        for i in defIdx {
            setRegCell(lbl: lblFieldPosition[i])
        }
    }
    
    func startGameTimer () {
        if ( DEBUG > 3 ) {
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
    
    func pauseGame( gamePaused: Bool) {
        if ( DEBUG > 3 ) {
            print( "in Pause Game" )
        }
        if ( gamePaused == true ) {
            gameTimerStarted = false
            startGameTimer()
        } else {
            gameTimer?.invalidate()
        }
    }
    
    @objc func decrementGameTime() {
        if ( DEBUG >= 3 ) {
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


    func startTimer() {
        if (  startDefenseTimer  == false ) {
            // we are going to disable the status buttons here.  This is pretty much when the play starts
            // and we can control when it will happen
            accessStatButton = false
            if ( DEBUG > 3 ) {
                print("Starting Defense Timer")
            }
            startDefenseTimer = true
            defenseTimer = Timer.scheduledTimer(timeInterval: defenseInterval, target: self, selector: #selector(moveDefense), userInfo: nil, repeats: true)
            moveDefense()
        }
        
    }
    
    func stoptimer() {
        if ( defenseTimer != nil ) {
            defenseTimer?.invalidate()
            if (defenseTimer?.isValid)! {
                print("Could not stop Timer!")
            }
        }
        if ( DEBUG > 3 ) {
            print("Stopping defense timer")
        }
    }
    
    func calculateToFirstDown () {
        if ( directionForward) {
            toFirstDown = firstDownMarker - fieldPos
        } else {
            toFirstDown = fieldPos - firstDownMarker
        }
    }
    
    
    func runnerTackled() ->  Bool {
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
    
    func checkforTouchDown() -> Bool {
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
    
    func setPlayDirection() {
        if (directionForward ) {
            directionForward = false
        } else {
            directionForward = true
        }
        if ( DEBUG > 3 ) {
            print("Setting playDirection to \(directionForward)")
        }
        
    }
    
    func endOfPlayIncrements() {
        
        startDefenseTimer = false
        
        if ( DEBUG > 3 ) {
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
            
            
            if ( toFirstDown <= 0) {
                if ( DEBUG > 3 ) {
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
                            if ( DEBUG > 3 ) {
                                print("Setting firstdown marker to 100")
                            }
                            firstDownMarker = 100
                        }
                    } else {
                        firstDownMarker -= 10
                        if ( firstDownMarker < 0 ) {
                            if ( DEBUG > 3 ) {
                                print("Setting first Down maker to 0")
                            }
                            firstDownMarker =  0
                        }
                    }
                } else {
                    // increment current down
                    currentDown += 1
                    if ( DEBUG > 3 ) {
                        print("Current Down:\(currentDown)")
                    }
                }
                
            }
        }
    }
    
    func stopPlay() {
        // play is over, now we can allow access to the status buttons
        accessStatButton = true
        startOfDowns = false
        if ( DEBUG > 3 ) {
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

