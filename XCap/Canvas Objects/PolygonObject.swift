//
//  PolygonObject.swift
//  XCap
//
//  Created by chen on 2021/6/5.
//

import Foundation

import XCanvas

extension CanvasObject.Identifier {
    static let polygon = CanvasObject.Identifier("polygon")
}

class PolygonObject: CanvasObject {
    
    override var identifier: CanvasObject.Identifier? { .polygon }
    
    override var drawingStrategy: CanvasObject.DrawingStrategy {
        .default { (self.first?.count ?? 0) < 3 ? .push : .pushOrFinish }
    }
    
    var auxiliaryLineStyle: AuxiliaryLineStyle { .disconnected }
    
    private(set)
    var lines: [Line] = []
    
    override func didUpdateLayout() {
        super.didUpdateLayout()
        
        guard isFinishable, let points = self.first else { return }
        
        let range = 0..<points.endIndex
        
        lines.removeAll()
        
        for i in range {
            let j = (i + 1) % points.count
            let line = Line(from: points[i], to: points[j])
            lines.append(line)
        }
    }
    
    override func createLayoutBrushes() -> [Drawable] {
        !isFinishable ? super.createLayoutBrushes() : []
    }
    
    override func createObjectBrushes() -> [Drawable] {
        guard isFinishable else { return super.createObjectBrushes() }
        
        let solid = CGPathDescriptor(method: .stroke(lineWidth), color: strokeColor) { path in
            guard let points = self.first else { return }
            path.addLines(between: points)
            if isFinished {
                path.closeSubpath()
            }
        }
        
        guard !isFinished else { return [solid] }
        
        let dashed = CGPathDescriptor(method: .defaultDash(width: lineWidth), color: strokeColor) { path in
            guard let first = self.first?.first, let last = self.first?.last else { return }
            path.addLines(between: [first, last])
        }
        
        return [solid, dashed]
    }
    
    override func selectTest(_ rect: CGRect) -> Bool {
        guard isFinishable else { return super.selectTest(rect) }
        guard !super.selectTest(rect) else { return true }
        guard let first = self.first?.first, let last = self.first?.last else { return false }
        return rect.canSelect(Line(from: last, to: first))
    }
    
}

extension PolygonObject: Measurable {
    
    var measurementIdentifier: Int { hashValue }
    
    var measurementTool: MeasurementTool { .polygon }
    
    var measurementTag: String { tag }
    
    private func calcArea(pixelLength: CGFloat) -> CGFloat {
        guard var points = self.first else { return 0 }
        var area: CGFloat = 0
        
        points = points.map { CGPoint(x: $0.x * pixelLength, y: $0.y * pixelLength) }
        
        for (i, point) in points.dropLast().enumerated() {
            area += point.x * points[i + 1].y
        }
        
        area += points.last!.x * points.first!.y
        
        for (i, point) in points.dropLast().enumerated() {
            area -= point.y * points[i + 1].x
        }
        
        area -= points.last!.y * points.first!.x
        area = abs(area) / 2
        return area
    }
    
    func measurands(pixelLength: CGFloat, unit: Unit) -> [Measurand] {
        let perimeter = lines.reduce(CGFloat(0)) { $0 + $1.distance * pixelLength }
        let area = calcArea(pixelLength: pixelLength)
        
        return [
            Measurand(type: .perimeter, value: perimeter, unit: unit),
            Measurand(type: .area, value: area, unit: unit),
        ]
    }
    
}
