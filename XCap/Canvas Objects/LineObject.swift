//
//  LineObject.swift
//  XCap
//
//  Created by scchn on 2021/4/29.
//

import Foundation

import XCanvas

extension CanvasObject.Identifier {
    static let lineSegment = CanvasObject.Identifier("lineSegment")
}

extension LineObject: AuxiliaryLineDrawable {
    var auxiliaryLineStyle: AuxiliaryLineStyle { .disconnected }
}

class LineObject: CanvasObject, Calibratable {
    
    override var identifier: CanvasObject.Identifier? { .lineSegment }
    
    override var drawingStrategy: CanvasObject.DrawingStrategy {
        .default { self.first?.count != 2 ? .push : .finish }
    }
    
    private var line: Line?
    
    var distance: CGFloat? { line?.distance }
    
    var calibrationValue: CGFloat { distance ?? 0 }
    
    override func didUpdateLayout() {
        super.didUpdateLayout()
        guard let points = first, points.count == 2 else { return }
        line = Line(from: points[0], to: points[1])
    }
    
    override func createLayoutBrushes() -> [Drawable] { [] }
    
    override func createObjectBrushes() -> [Drawable] {
        guard let line = line else { return [] }
         
        let desc = CGPathDescriptor(method: .stroke(lineWidth), color: strokeColor) { path in
            let len = lineWidth * lineWidth + 5
            let mid1 = line.mid.extended(length: len, angle: line.angle + .pi / 2)
            let mid2 = line.mid.extended(length: len, angle: line.angle - .pi / 2)
            
            path.addLines(between: [mid1, mid2])
            path.addLine(line)
        }
        
        return [desc]
    }
    
}

extension LineObject: Measurable {
    
    var measurementIdentifier: Int { hashValue }
    
    var measurementTool: MeasurementTool { .lineSegment }
    
    var measurementTag: String { tag }
    
    func measurands(pixelLength: CGFloat, unit: Unit) -> [Measurand] {
        guard let dist = distance else { return [] }
        return [
            Measurand(type: .length, value: dist * pixelLength, unit: unit)
        ]
    }
    
}
