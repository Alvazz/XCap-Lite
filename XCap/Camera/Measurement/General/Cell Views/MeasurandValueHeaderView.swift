//
//  MeasurandValueHeaderView.swift
//  XCap
//
//  Created by chen on 2021/5/31.
//

import Cocoa

class MeasurandValueHeaderView: NSTableCellView {
    
    private var viewModel: MeasurementResult!
    
    func bind(to viewModel: MeasurementResult) {
        textField?.stringValue = viewModel.tag
        self.viewModel = viewModel
    }
    
    @IBAction func textFieldAction(_ sender: NSTextField) {
        NotificationCenter.default.post(
            name: .didPerformMeasurementListAction,
            object: MeasurementListAction.changeObjectTag(viewModel.identifier, sender.stringValue)
        )
    }
    
}
