//
//  ScaleNameCellView.swift
//  XCap
//
//  Created by scchn on 2021/5/31.
//

import Cocoa

class ScaleNameCellView: NSTableCellView {
    
    var item: ScaleListViewModel.ListItem!
    var editHandler: ((String) -> Void)?
    
    func bind(to viewModel: ScaleListViewModel.ListItem) {
        item = viewModel
    }
    
    @IBAction func textFieldAction(_ sender: NSTextField) {
        let name = sender.stringValue.trimmingCharacters(in: .whitespaces)
        
        guard !name.isEmpty else {
            sender.stringValue = item.name
            return
        }
        
        sender.stringValue = name
        
        guard name != item.name else { return }
        
        editHandler?(name)
    }
    
}
