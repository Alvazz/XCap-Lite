//
//  CGContext+Ext.swift
//  XCap
//
//  Created by chen on 2021/6/11.
//

import Foundation
import AVFoundation.AVUtilities

extension CGContext {
    
    func setContentSize(_ contentSize: CGSize, inside boundingRect: CGRect, flipOptions: FlipOptions = []) {
        var validRect = AVMakeRect(aspectRatio: contentSize, insideRect: boundingRect)
        var mx = validRect.width / contentSize.width
        var my = validRect.height / contentSize.height
        
        if flipOptions.contains(.horizontal) {
            validRect.origin.x += validRect.width
            mx *= -1
        }
        
        if flipOptions.contains(.vertical) {
            validRect.origin.y += validRect.height
            my *= -1
        }
        
        translateBy(x: validRect.origin.x, y: validRect.origin.y)
        scaleBy(x: mx, y: my)
    }
    
}
