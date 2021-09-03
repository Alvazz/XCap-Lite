//
//  NSScreen+Ext.swift
//  XCap
//
//  Created by chen on 2021/5/11.
//

import Cocoa

// NSWindow.didChangeScreenNotification

extension NSScreen {
    
    var displayID: CGDirectDisplayID {
        let key = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
        return (deviceDescription[key] as! NSNumber).uint32Value
    }
    
    var pixelSize: CGSize {
        (deviceDescription[.size] as! NSValue).sizeValue
    }
    
    var physicalSize: CGSize {
        CGDisplayScreenSize(displayID)
    }
    
}
