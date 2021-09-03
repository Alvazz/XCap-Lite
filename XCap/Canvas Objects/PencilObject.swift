//
//  PencilObject.swift
//  XCap
//
//  Created by scchn on 2021/5/4.
//

import Foundation

import XCanvas

extension CanvasObject.Identifier {
    static let pencil = CanvasObject.Identifier("pencil")
}

class PencilObject: CanvasObject {
    
    override var identifier: CanvasObject.Identifier? { .pencil }

    override var drawingStrategy: CanvasObject.DrawingStrategy { .continuous(nil) }
    
    override func createLayoutBrushes() -> [Drawable] {
        []
    }
    
    override func createObjectBrushes() -> [Drawable] {
        guard isFinished else { return super.createObjectBrushes() }
        
        let descriptor = CGPathDescriptor(method: .stroke(lineWidth), color: strokeColor) { path in
            for points in self where points.count > 1 {
                let subpath = CGMutablePath()
                
                for (i, point) in points.enumerated() {
                    var previousPreviousPoint = points.first!
                    var previousPoint = points.first!
                    let currentPoint = point

                    if i >= 3 {
                        previousPreviousPoint = points[i - 2]
                    }

                    if i >= 2 {
                        previousPoint = points[i - 1]
                    }

                    let mid1 = previousPoint.mid(with: previousPreviousPoint)
                    let mid2 = currentPoint.mid(with: previousPoint)

                    subpath.move(to: mid1)
                    subpath.addQuadCurve(to: mid2, control: previousPoint)
                }

                path.addPath(subpath)
            }
        }
        
        return [descriptor]
    }

}
