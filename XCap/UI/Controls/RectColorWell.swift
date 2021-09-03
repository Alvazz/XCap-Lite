//
//  RectColorWell.swift
//  XCap
//
//  Created by scchn on 2021/5/25.
//

import Cocoa

@IBDesignable
class RectColorWell: NSColorWell {
    
    @IBInspectable
    var isFilled: Bool = true
    
    private func drawRect(_ rect: CGRect, color: NSColor, fill: Bool, lineWidth: CGFloat = 1, in ctx: CGContext) {
        if fill {
            ctx.addRect(rect)
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
        } else {
            ctx.addRect(rect)
            ctx.setLineWidth(lineWidth)
            ctx.setStrokeColor(color.cgColor)
            ctx.strokePath()
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let rect = bounds.insetBy(dx: 0.5, dy: 0.5)
        let borderColor: NSColor = isActive ? .controlColor : .tertiaryLabelColor
        
        if isFilled {
            drawRect(rect, color: color, fill: true, in: ctx)
        } else {
            let lineWidth: CGFloat = 10
            drawRect(rect, color: color, fill: false, lineWidth: lineWidth, in: ctx)
            
            let inset = round(lineWidth / 2)
            drawRect(rect.insetBy(dx: inset, dy: inset), color: borderColor, fill: false, in: ctx)
        }
        
        drawRect(rect, color: borderColor, fill: false, in: ctx)
    }
    
}
