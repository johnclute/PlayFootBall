//
//  objectMultipliers.swift
//  Play FootBalll
//
//  Created by John Clute on 6/10/18.
//  Copyright © 2018 creativeApps. All rights reserved.
//

import Foundation

class objectMultiplierClass {
    let deviceDim = [667, 375]
    let DEBUG1 = 1
    let DEBUG2 = 2
    let DEBUG3 = 3
    let DEBUG4 = 4
    let DEBUG5 = 5
    let CURRENTLEVEL = 0
    
    // Score board information
    let scoreboardTextFieldHeight = 0.2963
    
    // Playing field information
    public let fieldDimensions = [153, 375]
    public let footballPlayerDim = [21,8]
    
    
    // Controller information
    public let controlsDim = [222, 320]
    
    public func calcLabelFont( ) -> Float32 {
        var rtHeight: Float32 = 0
        let ratio = Float32((14/80.5) * (1/2))
        rtHeight = (ratio + 1.0)
        return rtHeight
    }
    
    public func calcTextFieldFont() -> Float32 {
        var rtHeight: Float32 = 0
        let ratio = Float32((24/80.5) * (1/4))
        rtHeight = (ratio + 1.0 )
        if ( DEBUG2 == CURRENTLEVEL ) {
            print("Height: \(rtHeight)")
        }
        return rtHeight
    }
    
    public func calcPlayerFieldRatio() -> Float32 {
        var rtHeight: Float32 = 0
        let ratio = Float32(9.5/163)
        rtHeight = (ratio + 1.0)
        return rtHeight
    }
    
    public func getRatio( item: Float32, container: Float32 ) -> Float32 {
        let ratio = item / container
        return ratio
    }
    
    public func getSizeOfItem( container: Float32, ratio: Float32 ) -> Float32 {
        // using this function to get the size of a box so we can get teh correct size of the font
        let tmp = (container * ratio)
        let returnSize = tmp * (2/3)
        return returnSize
    }
    
}
