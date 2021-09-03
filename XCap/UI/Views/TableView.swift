//
//  TableView.swift
//  XCap
//
//  Created by chen on 2021/6/1.
//

import Cocoa

class TableView: NSTableView {
    
    var didDoubleClickRow: ((Int) -> Void)?
    var menuHandler: ((NSEvent, Int?) -> NSMenu?)?
    
    private func _row(with event: NSEvent) -> Int? {
        let point = convert(event.locationInWindow, from: nil)
        let row = row(at: point)
        return row == -1 ? nil : row
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        guard let handler = didDoubleClickRow, event.clickCount == 2 else { return }
        if let row = _row(with: event) {
            handler(row)
        }
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        guard let handler = menuHandler else { return super.menu(for: event) }
        let row = _row(with: event)
        return handler(event, row)
    }
    
}
