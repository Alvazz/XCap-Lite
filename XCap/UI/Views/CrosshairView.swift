//
//  CrosshairView.swift
//  XCap
//
//  Created by chen on 2021/4/23.
//

import Cocoa
import AVFoundation.AVUtilities

class CrosshairView: NSView {
    
    var color: NSColor = .black {
        didSet { needsDisplay = true }
    }
    
    var lineWidth: CGFloat = 1 {
        didSet { needsDisplay = true }
    }
    
    var contentSize: CGSize = .zero {
        didSet { needsDisplay = true }
    }
    
    var flipOptions: FlipOptions = [] {
        didSet { needsDisplay = true }
    }
    
    private func draw(contentSize: CGSize, insideRect boundingRect: CGRect, in ctx: CGContext) {
        guard contentSize != .zero else { return }
        
        ctx.setContentSize(contentSize, inside: boundingRect)
        
        let midX = (contentSize.width) / 2
        let midY = (contentSize.height) / 2
        let maxX = contentSize.width
        let maxY = contentSize.height
        
        ctx.addLines(between: [
            CGPoint(x: midX, y: 0),
            CGPoint(x: midX, y: maxY),
        ])
        ctx.addLines(between: [
            CGPoint(x: 0   , y: midY),
            CGPoint(x: maxX, y: midY),
        ])
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(color.cgColor)
        ctx.strokePath()
    }
    
    func drawSnapshot(contentSize: CGSize) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let boundingRect = CGRect(origin: .zero, size: contentSize)
        
        ctx.saveGState()
        draw(contentSize: contentSize, insideRect: boundingRect, in: ctx)
        ctx.restoreGState()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        draw(contentSize: contentSize, insideRect: bounds, in: ctx)
    }
    
}
