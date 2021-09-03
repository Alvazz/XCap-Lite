//
//  PolylineObject.swift
//  XCap
//
//  Created by chen on 2021/4/30.
//

import Foundation

import XCanvas

extension CanvasObject.Identifier {
    static let polyline = CanvasObject.Identifier("polyline")
}

extension PolylineObject: AuxiliaryLineDrawable {
    var auxiliaryLineStyle: AuxiliaryLineStyle { .disconnected }
}

class PolylineObject: CanvasObject {
    
    override var identifier: CanvasObject.Identifier? { .polyline }
    
    override var drawingStrategy: CanvasObject.DrawingStrategy {
        .default { (self.first?.count ?? 0) < 2 ? .push : .pushOrFinish }
    }
    
    var distances: [CGFloat] {
        guard isFinishable, let points = last else { return [] }
        var lastPoint = points[0]
        return points[1...].map { point in
            let dist = lastPoint.distance(with: point)
            lastPoint = point
            return dist
        }
    }
    
    override func createLayoutBrushes() -> [Drawable] { [] }
    
}

extension PolylineObject: Measurable {
    
    var measurementIdentifier: Int { hashValue }
    
    var measurementTool: MeasurementTool { .polyline }
    
    var measurementTag: String { tag }
    
    func measurands(pixelLength: CGFloat, unit: Unit) -> [Measurand] {
        let dists = distances.map { $0 * pixelLength }
        let sum = dists.reduce(0, +)
        let distMeasurands = dists.map { dist in
            Measurand(type: .length, value: dist, unit: unit)
        }
        let sumMeasurand = Measurand(type: .sum, value: sum, unit: unit)
        return distMeasurands + [sumMeasurand]
    }
    
}
