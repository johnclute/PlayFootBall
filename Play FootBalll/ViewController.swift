//
//  ViewController.swift
//  Play FootBalll
//
//  Created by John Clute on 5/23/18.
//  Copyright © 2018 creativeApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let sizeModifier = objectMultiplierClass()
    
    
    /*
     variables needed by game
     */
    var blinkTimer: Timer?
    var fieldTimer: Timer?
    /*
     Outlets, Textfields, labels and buttons
     */
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
    @IBOutlet var fldLocation: [UILabel]!
    
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
        let y = downs.font?.pointSize
        let y2 = lblDown.font?.pointSize
        let fntSz = sizeModifier.calcTextFieldFont()
        let newFnt = UIFont(name: downs.font!.fontName, size: CGFloat(CGFloat(fntSz) * y!))
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
                
    }
    
    override func didReceiveMemoryWarning() {
        //      super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Controller Button Actions
    */
    //Status Key
    @IBAction func statusPressed(_ sender: Any) {
    }
    
    @IBAction func statusFinisedPressing(_ sender: Any) {
    }
    
    @IBAction func scorePressed(_ sender: Any) {
    }
    
    @IBAction func scoreFinishedPressing(_ sender: Any) {
    }
    
    @IBAction func kickPressed(_ sender: Any) {
    }
    
    @IBAction func runPressed(_ sender: Any) {
    }
    
    @IBAction func upPressed(_ sender: Any) {
    }
    
    @IBAction func downPressed(_ sender: Any) {
    }
    
    @IBAction func powerSwitchTouched(_ sender: Any) {
        if ( powerButton.isOn == true ) {
   //         gameStarted()
        } else {
  //          gameStopped()
        }
    }
    
    @IBAction func programSwitchTouched(_ sender: Any) {
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
        let sz = fldLocation.count - 1
        for i in 0...sz {
            fldLocation[i].text = "-"
        }
    }
    
    @objc func clearField() {
 //       let sz = fldLocation.count - 1
 //       print("sz = \(sz)")
 //       for i in 0...sz {
 //           fldLocation[i].text = ""
 //           print("i = \(i)")
 //       }
    }
    
/*    func gameStarted () {
        turnOnScoreBoard()
        blinkTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(turnOffScoreBoard), userInfo: nil, repeats: false)
        lightUpField()
        fieldTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(clearField), userInfo: nil, repeats: false)
        statusButton.isEnabled = true
        scoreButton.isEnabled = true
        runRightLeftButton.isEnabled = true
        upButton.isEnabled = true
        downButton.isEnabled = true
    }
    
    func gameStopped() {
        statusButton.isEnabled = false
        scoreButton.isEnabled = false
        runRightLeftButton.isEnabled = false
        upButton.isEnabled = false
        downButton.isEnabled = false
        
    }
*/
    

}

