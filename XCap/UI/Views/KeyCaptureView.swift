//
//  KeyCaptureView.swift
//  XCap
//
//  Created by chen on 2021/4/27.
//

import Cocoa

class KeyCaptureView: NSView {
    
    override var acceptsFirstResponder: Bool { true }
    
    var keyEquivalentHandler: ((Int, NSEvent.ModifierFlags) -> Bool)?
    var flagsChangeHandler: ((NSEvent.ModifierFlags) -> Void)?
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard !super.performKeyEquivalent(with: event) else { return true }
        let k = Int(event.keyCode)
        let m = event.modifierFlags
        return keyEquivalentHandler?(k, m) ?? false
    }
    
    override func flagsChanged(with event: NSEvent) {
        flagsChangeHandler?(event.modifierFlags.intersection(.deviceIndependentFlagsMask))
        super.flagsChanged(with: event)
    }
    
}
