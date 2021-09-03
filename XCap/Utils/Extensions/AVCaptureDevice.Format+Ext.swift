//
//  AVCaptureDevice.Format+Ext.swift
//  XCap
//
//  Created by scchn on 2021/4/22.
//

import AVFoundation

extension AVCaptureDevice.Format {
    
    var localizedName: String {
        let name = name ?? "N/A"
        let dim = dimensions
        return String(format: "%-4d x %-4d (\(name))", Int(dim.width), Int(dim.height))
    }
    
}
