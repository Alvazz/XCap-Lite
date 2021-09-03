//
//  AngleObject.swift
//  XCap
//
//  Created by chen on 2021/5/7.
//

import Foundation

import XCanvas

extension CanvasObject.Identifier {
    static let angle = CanvasObject.Identifier("angle")
}

extension AngleObject: AuxiliaryLineDrawable {
    var auxiliaryLineStyle: AuxiliaryLineStyle { .disconnected }
}

class AngleObject: CanvasObject {
    
    override var identifier: CanvasObject.Identifier? { .angle }
    
    override var drawingStrategy: CanvasObject.DrawingStrategy {
        .default {
            guard self.map({ $0.count }) != [2, 2] else { return .finish }
            return self.last?.count != 2 ? .push : .pushToNext
        }
    }
    
    private var arcRadius: CGFloat { lineWidth * lineWidth + 20 }
    
    private var result: AngleResult? {
        guard isFinishable else { return nil }
        let line1 = Line(from: self[0][0], to: self[0][1])
        let line2 = Line(from: self[1][0], to: self[1][1])
        return AngleResult(line1: line1, line2: line2)
    }
    
    var angle: CGFloat? {
        guard let result = result else { return nil }
        return calcAngle(result.intersection, result.line1.from, result.line2.from)
    }
    
    override func createLayoutBrushes() -> [Drawable] {
        isFinishable ? [] : super.createLayoutBrushes()
    }
    
    override func createObjectBrushes() -> [Drawable] {
        guard let result = result else { return super.createObjectBrushes() }
        
        let desc1 = CGPathDescriptor(method: .stroke(lineWidth), color: strokeColor) { path in
            path.addLines(between: [result.line1.from, result.intersection])
            path.addLines(between: [result.line2.from, result.intersection])
        }
        let desc2 = CGPathDescriptor(method: .defaultDash(width: lineWidth), color: strokeColor) { path in
            let arc = result.getArc(radius: arcRadius)
            path.addLines(between: [result.line1.to, result.intersection])
            path.addLines(between: [result.line2.to, result.intersection])
            path.addArc(arc)
            path.addLine(to: result.intersection)
        }
        let desc3 = CGPathDescriptor(method: .fill, color: strokeColor) { path in
            let width: CGFloat = 10
            path.addArrow(at: result.line1.from, width: width, rotation: result.line1.angle)
            path.addArrow(at: result.line1.to, width: width, rotation: result.line1.angle)
            path.addArrow(at: result.line2.from, width: width, rotation: result.line2.angle)
            path.addArrow(at: result.line2.to, width: width, rotation: result.line2.angle)
        }
        
        return [desc1, desc2, desc3]
    }
    
    override func selectTest(_ rect: CGRect) -> Bool {
        if let result = result {
            if rect.canSelect(result.line1) ||  rect.canSelect(result.line2) || rect.canSelect(result.getArc(radius: arcRadius)) {
                return true
            }
            
            let line1 = Line(from: result.intersection, to: result.line1.to)
            if rect.canSelect(line1) {
                return true
            }
            
            let line2 = Line(from: result.intersection, to: result.line2.to)
            return rect.canSelect(line2)
        }
        return super.selectTest(rect)
    }
    
}

extension AngleObject: Measurable {
    
    var measurementIdentifier: Int { hashValue }
    
    var measurementTool: MeasurementTool { .angle }
    
    var measurementTag: String { tag }
    
    func measurands(pixelLength: CGFloat, unit: Unit) -> [Measurand] {
        guard let angle = angle else { return [] }
        let value1 = Angle.radians(angle).toDegrees().value
        let value2 = 180 - value1
        let value3 = 360 - value1
        return [
            Measurand(type: .angle,  value: value1, unit: unit),
            Measurand(type: .angle1, value: value2, unit: unit),
            Measurand(type: .angle2, value: value3, unit: unit),
        ]
    }
    
}

fileprivate struct AngleResult {

    var line1: Line
    var line2: Line
    var intersection: CGPoint
    
    init?(line1: Line, line2: Line) {
        guard case let .intersect(intersection) = line1.intersection(line2) else { return nil }
        self.line1 = line1
        self.line2 = line2
        self.intersection = intersection
    }
    
    func getArc(radius: CGFloat) -> Arc {
        Arc.vertex(intersection, line1.from, line2.from, radius: radius)
    }
    
}
