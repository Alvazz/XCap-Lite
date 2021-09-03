//
//  SquareObject.swift
//  XCap
//
//  Created by scchn on 2021/5/7.
//

import Foundation

import XCanvas

extension CanvasObject.Identifier {
    static let square = CanvasObject.Identifier("square")
}

extension SquareObject: AuxiliaryLineDrawable {
    var auxiliaryLineStyle: AuxiliaryLineStyle { .connected }
}

class SquareObject: CanvasObject {
    
    override var identifier: CanvasObject.Identifier? { .square }
    
    override var drawingStrategy: CanvasObject.DrawingStrategy {
        .default { self.first?.count != 2 ? .push : .finish }
    }
    
    private var result: (line: Line, corners: [CGPoint])?
    
    private var width: CGFloat? {
        guard let dist = result?.line.distance else { return nil }
        return dist / sqrt(2)
    }
    
    var size: CGSize? {
        guard let width = width else { return nil }
        return CGSize(width: width, height: width)
    }
    
    override func didUpdateLayout() {
        super.didUpdateLayout()
        guard first?.count == 2, let points = first else { return }
        let line = Line(from: points[0], to: points[1])
        let center = line.mid
        let len = line.distance / 2
        let corners = [
            line.from,
            center.extended(length: len, angle: line.angle + .pi / 2),
            line.to,
            center.extended(length: len, angle: line.angle - .pi / 2)
        ]
        
        result = (line, corners)
    }
    
    override func createObjectBrushes() -> [Drawable] {
        guard let (_, corners) = result else { return super.createObjectBrushes() }
        
        let desc = CGPathDescriptor(method: .stroke(lineWidth), color: strokeColor) { path in
            path.addLines(between: corners)
            path.closeSubpath()
        }
        
        return [desc]
    }
    
    override func selectTest(_ rect: CGRect) -> Bool {
        guard let (_, corners) = result else { return false }
        return rect.canSelect(linesBetween: corners, isClosed: true)
    }
    
}

extension SquareObject: Measurable {
    
    var measurementIdentifier: Int { hashValue }
    
    var measurementTool: MeasurementTool { .square }
    
    var measurementTag: String { tag }
    
    func measurands(pixelLength: CGFloat, unit: Unit) -> [Measurand] {
        guard let size = size else { return [] }
        let w = size.width * pixelLength
        let p = w * 2 + w * 2
        let a = w * w
        return [
            Measurand(type: .width, value: w, unit: unit),
            Measurand(type: .perimeter, value: p, unit: unit),
            Measurand(type: .area, value: a, unit: unit),
        ]
    }
    
}
