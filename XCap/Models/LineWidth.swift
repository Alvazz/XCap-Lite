//
//  LineWidth.swift
//  XCap
//
//  Created by chen on 2021/5/28.
//

import Cocoa

fileprivate let widths: [CGFloat] = [1, 2, 3]

@objc
enum LineWidth: Int, CaseIterable {
    
    case width1
    case width2
    case width3
    
    init?(width: CGFloat) {
        guard let index = widths.firstIndex(of: width) else { return nil }
        self.init(rawValue: index)
    }
    
    var width: CGFloat { widths[rawValue] }
    
    var image: NSImage {
        let size = CGSize(width: 16, height: 16)
        return NSImage(size: size, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.translateBy(x: 0, y: rect.midY + 0.5)
            ctx.setLineWidth(width)
            ctx.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: rect.maxX, y: 0)])
            ctx.setStrokeColor(NSColor.controlColor.cgColor)
            ctx.strokePath()
            return true
        }
    }
}
