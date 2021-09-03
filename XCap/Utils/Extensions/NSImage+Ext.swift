//
//  NSImage+Ext.swift
//  XCap
//
//  Created by scchn on 2021/4/28.
//

import Cocoa

fileprivate extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

extension NSImage {
    
    func representation(using fileType: NSBitmapImageRep.FileType) -> Data? {
        tiffRepresentation?.bitmap?.representation(using: fileType, properties: [:])
    }
    
    convenience init?(pixelBuffer: CVPixelBuffer) {
        let w = CVPixelBufferGetWidth(pixelBuffer)
        let h = CVPixelBufferGetHeight(pixelBuffer)
        let rect = CGRect(x: 0, y: 0, width: w, height: h)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciImage, from: rect) else { return nil }
        let size = NSSize(width: cgImage.width, height: cgImage.height)
        self.init(cgImage: cgImage, size: size)
    }
    
    func resized(_ size: CGSize) -> NSImage {
        let image = NSImage(size: size)
        let rect = NSRect(origin: .zero, size: size)
        
        image.lockFocus()
        draw(in: rect)
        image.unlockFocus()
        
        return image
    }
    
    func inset(dx: CGFloat, dy: CGFloat) -> NSImage {
        let image = NSImage(size: size)
        let rect = CGRect(origin: .zero, size: size)
            .insetBy(dx: dx, dy: dy)
        
        image.lockFocus()
        draw(in: rect)
        image.unlockFocus()
        
        return image
    }
    
    func fliped(flipOptions: FlipOptions) -> NSImage {
        NSImage(size: size, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            if flipOptions.contains(.horizontal) {
                ctx.translateBy(x: rect.width, y: 0)
                ctx.scaleBy(x: -1, y: 1)
            }
            if flipOptions.contains(.vertical) {
                ctx.translateBy(x: 0, y: rect.height)
                ctx.scaleBy(x: 1, y: -1)
            }
            self.draw(in: rect)
            return true
        }
    }
    
    func cropped(rect: CGRect) -> NSImage {
        let result = NSImage(size: rect.size)
        let destRect = CGRect(origin: .zero, size: result.size)
        
        result.lockFocus()
        draw(in: destRect, from: rect, operation: .copy, fraction: 1.0)
        result.unlockFocus()
        
        return result
    }
    
}
