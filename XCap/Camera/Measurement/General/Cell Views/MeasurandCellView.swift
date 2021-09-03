//
//  MeasurandCellView.swift
//  XCap
//
//  Created by chen on 2021/5/31.
//

import Cocoa

class MeasurandCellView: NSTableCellView {
    
    func bind(to viewModel: Measurand) {
        textField?.stringValue = viewModel.type.description
    }
    
}
