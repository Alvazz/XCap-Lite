//
//  HelpWindowController.swift
//  XCap
//
//  Created by chen on 2021/7/3.
//

import Cocoa

class HelpWindowController: NSWindowController, NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.delegate = self
        window?.isMovableByWindowBackground = true
    }
    
    @objc
    func cancel(_ sender: Any?) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = { [weak self] in
            guard let self = self else { return }
            self.close()
            self.window?.alphaValue = 1
        }
        window?.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        defer { cancel(nil) }
        return false
    }
    
}
