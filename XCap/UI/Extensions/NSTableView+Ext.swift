//
//  NSTableView+Ext.swift
//  XCap
//
//  Created by scchn on 2021/5/26.
//

import Cocoa

extension NSTableView {
    
    var altSelectedRow: Int? { selectedRow == -1 ? nil : selectedRow }

    func makeView<T: NSTableCellView>(_ type: T.Type, identifier: NSUserInterfaceItemIdentifier? = nil) -> T {
        let identifier = identifier ?? NSUserInterfaceItemIdentifier(String(describing: type))
        guard let view = makeView(withIdentifier: identifier, owner: nil) as? T else {
            fatalError()
        }
        return view
    }

}
