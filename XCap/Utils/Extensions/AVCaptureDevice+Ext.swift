//
//  AVCaptureDevice+Ext.swift
//  XCap
//
//  Created by scchn on 2021/7/2.
//

import AVFoundation

extension AVCaptureDevice {
    
    var productID: Int? {
        guard uniqueID.count >= 8 else { return nil }
        let end = uniqueID.endIndex
        let start = uniqueID.index(end, offsetBy: -4)
        return Int(uniqueID[start..<end], radix: 16)
    }
    
    var vendorID: Int? {
        guard uniqueID.count >= 8 else { return nil }
        let end = uniqueID.index(uniqueID.endIndex, offsetBy: -4)
        let start = uniqueID.index(end, offsetBy: -4)
        return Int(uniqueID[start..<end], radix: 16)
    }
    
}
