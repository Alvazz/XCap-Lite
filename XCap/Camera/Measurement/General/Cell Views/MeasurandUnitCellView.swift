//
//  MeasurandUnitCellView.swift
//  XCap
//
//  Created by chen on 2021/5/31.
//

import Cocoa

class MeasurandUnitCellView: NSTableCellView {
    
    func bind(to viewModel: Measurand) {
        textField?.stringValue = viewModel.unitDescriptionByType()
    }
    
}
