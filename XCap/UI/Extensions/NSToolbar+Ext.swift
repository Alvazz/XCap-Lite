//
//  NSToolbar+Ext.swift
//  XCap
//
//  Created by scchn on 2021/5/21.
//

import Cocoa

extension NSToolbar {
    
    func itemView<T: NSView>(_ type: T.Type, identifier: NSToolbarItem.Identifier) -> T? {
        let item = items.first { item in item.itemIdentifier == identifier }
        return item?.view as? T
    }
    
}
