//
//  BaseRectangleObject.swift
//  XCap
//
//  Created by scchn on 2021/5/3.
//

import Foundation

import XCanvas

class BaseRectangleObject: CanvasObject {
    
    private var drawingOrder: [Int] = [0, 1, 2, 3, 7, 4, 5, 6]
    
    override var drawingStrategy: CanvasObject.DrawingStrategy {
        .default { self.first?.count != 8 ? .push : .finish }
    }
    
    var corners: [CGPoint]? {
        guard isFinishable, let points = self.first else { return nil }
        return drawingOrder.map { index in points[index] }
    }
    
    var size: CGSize? {
        guard let corners = corners else { return nil }
        let width = corners[0].distance(with: corners[2])
        let height = corners[0].distance(with: corners[6])
        return CGSize(width: width, height: height)
    }
    
    required init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    init(rect: CGRect) {
        super.init()
        let point1 = CGPoint(x: rect.minX, y: rect.minY)
        let point2 = CGPoint(x: rect.maxX, y: rect.maxY)
        push(point: point1)
        push(point: point2)
        markAsFinished()
    }
    
    override func push(point: CGPoint) {
        guard !isEmpty else { return super.push(point: point) }
        
        let origin = self[0][0]
        let line = Line(from: origin, to: point)
        let dx = line.dx
        let dy = line.dy
        
        super.push(point: origin.applying(.init(translationX: dx / 2, y: 0)))
        super.push(point: origin.applying(.init(translationX: dx,     y: 0)))
        super.push(point: origin.applying(.init(translationX: dx,     y: dy / 2)))
        super.push(point: origin.applying(.init(translationX: dx / 2, y: dy)))
        super.push(point: origin.applying(.init(translationX: 0,      y: dy)))
        super.push(point: origin.applying(.init(translationX: 0,      y: dy / 2)))
        super.push(point: point)
    }
    
    override func createLayoutBrushes() -> [Drawable] {
        []
    }
    
    override func createObjectBrushes() -> [Drawable] {
        guard let corners = corners else { return [] }
        let rect = CGPathDescriptor(method: .stroke(lineWidth), color: strokeColor) { path in
            path.addLines(between: corners)
            path.closeSubpath()
        }
        return [rect]
    }
    
    override func selectTest(_ rect: CGRect) -> Bool {
        guard let first = first, isFinishable else { return false }
        let points = drawingOrder.map { first[$0] }
        return rect.canSelect(linesBetween: points, isClosed: true)
    }
    
    override func relations() -> [IndexPath : [CanvasObject.Relation]] {
        [
            .init(item: drawingOrder[0], section: 0): [
                .init(indexPath: IndexPath(item: drawingOrder[7], section: 0), offset: CGPoint(x: 1, y: 0.5)),
                .init(indexPath: IndexPath(item: drawingOrder[6], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[2], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[3], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: drawingOrder[2], section: 0): [
                .init(indexPath: IndexPath(item: drawingOrder[3], section: 0), offset: CGPoint(x: 1, y: 0.5)),
                .init(indexPath: IndexPath(item: drawingOrder[4], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[0], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[7], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: drawingOrder[4], section: 0): [
                .init(indexPath: IndexPath(item: drawingOrder[3], section: 0), offset: CGPoint(x: 1, y: 0.5)),
                .init(indexPath: IndexPath(item: drawingOrder[2], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[6], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[7], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: drawingOrder[6], section: 0): [
                .init(indexPath: IndexPath(item: drawingOrder[7], section: 0), offset: CGPoint(x: 1, y: 0.5)),
                .init(indexPath: IndexPath(item: drawingOrder[0], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[4], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[3], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            
            .init(item: drawingOrder[3], section: 0): [
                .init(indexPath: IndexPath(item: drawingOrder[4], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[2], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[3], section: 0), offset: CGPoint(x: 0, y: -1)),
            ],
            .init(item: drawingOrder[7], section: 0): [
                .init(indexPath: IndexPath(item: drawingOrder[0], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[6], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[7], section: 0), offset: CGPoint(x: 0, y: -1)),
            ],
            
            .init(item: drawingOrder[1], section: 0): [
                .init(indexPath: IndexPath(item: drawingOrder[1], section: 0), offset: CGPoint(x: -1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[0], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[2], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[7], section: 0), offset: CGPoint(x: 0, y: 0.5)),
                .init(indexPath: IndexPath(item: drawingOrder[3], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: drawingOrder[5], section: 0): [
                .init(indexPath: IndexPath(item: drawingOrder[5], section: 0), offset: CGPoint(x: -1, y: 0)),
                .init(indexPath: IndexPath(item: drawingOrder[4], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[6], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(indexPath: IndexPath(item: drawingOrder[3], section: 0), offset: CGPoint(x: 0, y: 0.5)),
                .init(indexPath: IndexPath(item: drawingOrder[7], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
        ]
    }
    
}
