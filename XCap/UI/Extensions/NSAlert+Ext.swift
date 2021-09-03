//
//  NSAlert+Ext.swift
//  XCap
//
//  Created by chen on 2021/5/9.
//

import Cocoa

extension NSAlert {
    
    convenience init(title: String, message: String = "", icon: NSImage? = nil, style: NSAlert.Style = .informational) {
        self.init()
        alertStyle = style
        messageText = title
        informativeText = message
        if let icon = icon {
            self.icon = icon
        }
    }
    
    static func yesNoAlert(title: String, message: String = "", style: NSAlert.Style = .informational) -> NSAlert {
        let alert = NSAlert(title: title, message: message, style: style)
        alert.addButton(withTitle: "Common.OK".localized())
        alert.addButton(withTitle: "Common.Cancel".localized())
        return alert
    }
    
    static func textFieldAlert(title: String, message: String = "", placeholder: String = "", `default`: String = "") -> NSAlert {
        let alert = NSAlert.yesNoAlert(title: title, message: message)
        
        // Text UI
        let textField = NSTextField()
        textField.frame.size = CGSize(width: 200, height: 21)
        textField.stringValue = `default`
        textField.placeholderString = placeholder
        
        // Install Text Field
        alert.accessoryView = textField
        
        return alert
    }
    
    func beginTextFieldSheetModal(
        for window: NSWindow,
        completionHandler: ((NSApplication.ModalResponse, String) -> Void)? = nil
    ) {
        guard let textField = accessoryView as? NSTextField else {
            fatalError("The accessory view is NOT a NSTextField")
        }
        
        beginSheetModal(for: window) { response in
            completionHandler?(response, textField.stringValue)
        }
        
        textField.becomeFirstResponder()
    }
    
}
