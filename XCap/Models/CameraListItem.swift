//
//  CameraListItem.swift
//  XCap
//
//  Created by scchn on 2021/4/21.
//

import Foundation
import AVFoundation

import DifferenceKit

struct CameraListItem: Equatable, Hashable {
    
    var uniqueID: String
    var name: String
    var manufacturer: String
    var modelID: String
    
    init(device: AVCaptureDevice) {
        uniqueID     = device.uniqueID
        modelID      = device.modelID
        
        #if DEMO_MODE
        name         = "Digital Microscope"
        manufacturer = "-"
        #else
        name         = device.localizedName
        manufacturer = device.manufacturer
        #endif
    }
    
}

extension CameraListItem: Differentiable {
    
    var differenceIdentifier: String { uniqueID }
    
}
