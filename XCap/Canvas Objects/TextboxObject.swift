//
//  TextboxObject.swift
//  XCap
//
//  Created by chen on 2021/5/8.
//

import Cocoa

import XCanvas

extension CanvasObject.Identifier {
    static let textbox = CanvasObject.Identifier("textbox")
}

class TextboxObject: BaseRectangleObject {
    
    override var identifier: CanvasObject.Identifier? { .textbox }
    
    override var isRotatable: Bool { false }
    
    private var drawingOrder: [Int] = [0, 1, 2, 3, 7, 4, 5, 6]
    
    @CanvasState
    var font: NSFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    
    @CanvasState
    var textColor: NSColor = .black
    
    @CanvasState
    var text: String = "Text"
    
    @CanvasState
    var drawsBackground = true
    
    var rect: CGRect? {
        guard isFinishable, let points = first else { return nil }
        let line = Line(from: points[drawingOrder[0]], to: points[drawingOrder[4]])
        let size = CGSize(width: line.dx, height: line.dy)
        return CGRect(origin: line.from, size: size)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    required init() {
        super.init()
        fillColor = .white
    }
    
    override func userInfo() -> Data? {
        let info = TextInfo(font: font, color: textColor, text: text)
        return try? JSONEncoder().encode(info)
    }
    
    override func applyUserInfo(_ data: Data) {
        guard let info = try? JSONDecoder().decode(TextInfo.self, from: data) else { return }
        font = info.font
        textColor = info.color
        text = info.text
    }
    
    override func createObjectBrushes() -> [Drawable] {
        guard let rect = rect else { return []}
        let bgDesc = CGPathDescriptor(method: .fill, color: fillColor) { path in
            if drawsBackground {
                path.addRect(rect)
            }
        }
        let rectDesc = CGPathDescriptor(method: .stroke(lineWidth), color: strokeColor) { path in
            path.addRect(rect)
        }
        return [bgDesc, rectDesc]
    }
    
    private func attributedString() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        return NSAttributedString(
            string: text,
            attributes: [.font: font, .foregroundColor: textColor, .paragraphStyle: paragraphStyle]
        )
    }
    
    override func draw(_ rect: CGRect, in ctx: CGContext) {
        super.draw(rect, in: ctx)
        
        if let rect = self.rect {
            let padding = font.pointSize / 3
            let contentRect = rect.insetBy(dx: padding, dy: padding)
            
            ctx.saveGState()
            ctx.clip(to: contentRect)
            
            attributedString().draw(in: contentRect)
            
            ctx.restoreGState()
        }
    }
    
    override func hitTest(_ point: CGPoint, range: CGFloat) -> Bool {
        rect?.insetBy(dx: -range, dy: -range).contains(point) ?? false
    }
    
    override func selectTest(_ aRect: CGRect) -> Bool {
        guard let rect = rect else { return false }
        return rect.intersects(aRect)
    }
    
}

fileprivate class TextInfo: Codable {
    
    var font: NSFont
    var color: NSColor
    var text: String
    
    init(font: NSFont, color: NSColor, text: String) {
        self.font = font
        self.color = color
        self.text = text
    }
    
    enum CodingKeys: String, CodingKey {
        case fontName
        case fontSize
        case color
        case text
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fontName = try container.decode(String.self, forKey: .fontName)
        let fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        font = NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        let xColor = try container.decode(XColor.self, forKey: .color)
        color = xColor.nsColor
        text = try container.decode(String.self, forKey: .text)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(font.fontName, forKey: .fontName)
        try container.encode(font.pointSize, forKey: .fontSize)
        try container.encode(color.xColor, forKey: .color)
        try container.encode(text, forKey: .text)
    }
    
}
