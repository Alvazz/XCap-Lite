//
//  CircleObject.swift
//  XCap
//
//  Created by scchn on 2021/4/29.
//

import Foundation

import XCanvas

extension CanvasObject.Identifier {
    static let circle = CanvasObject.Identifier("circle")
}

extension CircleObject: AuxiliaryLineDrawable {
    var auxiliaryLineStyle: AuxiliaryLineStyle { .connected }
}

class CircleObject: CanvasObject {
    
    override var identifier: CanvasObject.Identifier? { .circle }
    
    override var drawingStrategy: CanvasObject.DrawingStrategy {
        .default { self.first?.count != 3 ? .push : .finish }
    }
    
    private(set)
    var circle: Circle?
    
    override func didUpdateLayout() {
        super.didUpdateLayout()
        
        if let points = first, points.count == 3,
           let circle = Circle(points[0], points[1], points[2]),
           circle.radius != 0
        {
            self.circle = circle
        } else {
            self.circle = nil
        }
    }
    
    override func createObjectBrushes() -> [Drawable] {
        guard let circle = circle else { return super.createObjectBrushes() }
        
        let circleDesc = CGPathDescriptor(method: .stroke(lineWidth), color: strokeColor) { path in
            path.addCircle(circle)
        }
        let centerDesc = CGPathDescriptor(method: .fill, color: strokeColor) { path in
            path.addCircle(center: circle.center, radius: 1)
        }
        return [circleDesc, centerDesc]
    }
    
    override func hitTest(_ point: CGPoint, range: CGFloat) -> Bool {
        super.hitTest(point, range: range) || (circle?.center.contains(point, in: range) ?? false)
    }
    
    override func selectTest(_ rect: CGRect) -> Bool {
        guard let circle = circle else { return super.selectTest(rect) }
        return rect.canSelect(circle) || rect.contains(circle.center)
    }
    
}

extension CircleObject: Circular, Calibratable {
    
    var measurementIdentifier: Int { hashValue }
    
    var measurementTool: MeasurementTool { .circle }
    
    var measurementTag: String { tag }
    
    var center: CGPoint { circle?.center ?? .zero }
    
    var radius: CGFloat { circle?.radius ?? 0 }
    
    var calibrationValue: CGFloat { radius * 2 }
    
}
