//
//  TagView.swift
//  XCap
//
//  Created by chen on 2021/6/17.
//

import Cocoa
import AVFoundation.AVUtilities

import XCanvas

class TagView: NSView {
    
    private struct Item {
        var tag: String
        var point: CGPoint
    }
    
    private var items: [Item] = []
    
    var contentSize: CGSize = .zero {
        didSet { needsDisplay = true }
    }
    
    func update(with objects: [CanvasObject]) {
        var items: [Item] = []
        for object in objects {
            guard let path = object.path else { continue }
            let boundingBox = path.boundingBoxOfPath
            let center = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
            items.append(Item(tag: object.tag, point: center))
        }
        self.items = items
        needsDisplay = true
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
    
    private func draw(contentSize: CGSize, insideRect boundingRect: CGRect, in ctx: CGContext) {
        let borderColor = NSColor.black
        let backgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        let validRect = AVMakeRect(aspectRatio: contentSize, insideRect: boundingRect)
        let mx = validRect.width / contentSize.width
        let my = validRect.height / contentSize.height
        
        ctx.clip(to: validRect)
        ctx.translateBy(x: validRect.minX, y: validRect.minY)
        
        for item in items where !item.tag.isEmpty {
            let string = NSAttributedString(string: item.tag)
            let stringSize = string.size()
            let point = item.point
                .applying(.init(scaleX: mx, y: my))
                .applying(.init(translationX: -stringSize.width / 2, y: -stringSize.height / 2))
            let padding: CGFloat = 4
            let rect = CGRect(origin: point, size: stringSize)
                .insetBy(dx: -padding, dy: -padding)
            let rectPath = CGPath(roundedRect: rect, cornerWidth: 3, cornerHeight: 3, transform: nil)
            
            ctx.setStrokeColor(borderColor.cgColor)
            ctx.setFillColor(backgroundColor.cgColor)
            ctx.addPath(rectPath)
            ctx.drawPath(using: .fillStroke)
            
            string.draw(at: point)
        }
    }
    
    func drawSnapshot(contentSize: CGSize) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let boundingRect = CGRect(origin: .zero, size: contentSize)
        
        ctx.saveGState()
        draw(contentSize: contentSize, insideRect: boundingRect, in: ctx)
        ctx.restoreGState()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext, contentSize != .zero else { return }
        
        draw(contentSize: contentSize, insideRect: bounds, in: ctx)
    }
    
}
