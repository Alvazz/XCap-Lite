//
//  NSToolbarItem+Ext.swift
//  XCap
//
//  Created by scchn on 2021/4/21.
//

import Cocoa

extension NSToolbarItem {
    
    convenience init(
        identifier: NSToolbarItem.Identifier,
        label: String = "",
        paletteLabel: String? = nil,
        toolTip: String? = nil,
        content: AnyObject
    ) {
        self.init(itemIdentifier: identifier)
        
        self.label = label
        self.paletteLabel = paletteLabel ?? identifier.rawValue
        self.toolTip = toolTip
        self.autovalidates = autovalidates
        
        switch content {
        case let image as NSImage:
            self.image = image
        case let view as NSView:
            self.view = view
        default:
            assertionFailure("Invalid item content")
        }
        
        let menuItem: NSMenuItem = NSMenuItem()
        menuItem.submenu = nil
        menuItem.title = label
        self.menuFormRepresentation = menuItem
    }
    
}
