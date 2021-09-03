//
//  MeasurandValueCellView.swift
//  XCap
//
//  Created by chen on 2021/5/31.
//

import Cocoa

class MeasurandValueCellView: NSTableCellView {
    
    func bind(to viewModel: Measurand) {
        textField?.stringValue = UIHelper.text(viewModel.value)
    }
    
}
