//
//  SolidView.swift
//  
//
//  Created by chen on 2021/4/22.
//

import Cocoa

class SolidView: NSView {
    
    var color: NSColor {
        didSet { needsDisplay = true }
    }
    
    var clickHandler: ((CGPoint, Int) -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(color: NSColor) {
        self.color = color
        super.init(frame: .zero)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        color.setFill()
        bounds.fill()
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        clickHandler?(point, event.clickCount)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
    }
    
}
