//
//  MeasurandHeaderView.swift
//  XCap
//
//  Created by chen on 2021/5/31.
//

import Cocoa

class MeasurandHeaderView: NSTableCellView {
    
    func bind(to viewModel: MeasurementResult) {
        textField?.stringValue = "\(viewModel.measurementTool)"
        imageView?.image = viewModel.measurementTool.image
    }
    
}
