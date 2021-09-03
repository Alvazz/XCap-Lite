//
//  NSMenu+Ext.swift
//  XCap
//
//  Created by scchn on 2021/7/27.
//

import Cocoa

extension NSMenu {
    
    @discardableResult
    func addItem(localizedTitle title: String, action: Selector) -> NSMenuItem {
        addItem(withTitle: title.localized(), action: action, keyEquivalent: "")
    }
    
}
