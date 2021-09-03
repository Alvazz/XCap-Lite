//
//  PlainButton.swift
//  XCap
//
//  Created by scchn on 2020/12/23.
//

import Cocoa

class PlainButton: NSButton {
    
    // MARK: - Settings
    
    var cornerRadius: CGFloat = 0 {
        didSet { layer?.cornerRadius = cornerRadius }
    }
    
    var imageInset: CGVector = .zero {
        didSet { needsDisplay = true }
    }
    
    var borderWith: CGFloat = 3 {
        didSet { needsDisplay = true }
    }
    
    var borderColor: NSColor = .selectedMenuItemColor {
        didSet { needsDisplay = true }
    }
    
    var drawsBackground: Bool = false {
        didSet { needsDisplay = true }
    }
    
    var backgroundColor: NSColor = .controlBackgroundColor {
        didSet { needsDisplay = true }
    }
    
    // MARK: Init
    
    private func commonInit() {
        // Layer
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = cornerRadius
        // Button Properties
        isBordered = false
        imageScaling = .scaleProportionallyDown
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    convenience init(image: NSImage) {
        self.init()
        imagePosition = .imageOnly
        self.image = image
    }
    
    convenience init(title: String, image: NSImage) {
        self.init()
        self.imagePosition = .imageLeft
        self.title = title
        self.image = image
    }
    
    // MARK: - Tracking Area
    
    private var trackingArea: NSTrackingArea?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let area = trackingArea {
            removeTrackingArea(area)
        }
        let opt: NSTrackingArea.Options = [
            .activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved
        ]
        let area = NSTrackingArea(rect: bounds, options: opt,
                                  owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }
    
    // MARK: - Drawing
    
    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        ctx.saveGState()
        
        if drawsBackground {
            ctx.addRect(bounds)
            ctx.setFillColor(backgroundColor.cgColor)
            ctx.fillPath()
        }
        
        let orignalImage = image
        defer { image = orignalImage }
        
        if let oImage = orignalImage, imageInset != .zero {
            let m = oImage.size.height / bounds.height
            image = oImage.inset(dx: imageInset.dx * m, dy: imageInset.dy * m)
        }
        
        if isBordered {
            isBordered = false
            super.draw(dirtyRect)
            
            let borderPath = CGPath(
                roundedRect: bounds,
                cornerWidth: cornerRadius,
                cornerHeight: cornerRadius,
                transform: nil
            )
            ctx.addPath(borderPath)
            ctx.setLineWidth(borderWith)
            ctx.setStrokeColor(borderColor.cgColor)
            ctx.strokePath()
            isBordered = true
        } else {
            super.draw(dirtyRect)
        }
        
        ctx.restoreGState()
    }
    
}
