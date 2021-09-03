//
//  RectangleObject.swift
//  XCap
//
//  Created by chen on 2021/6/9.
//

import Foundation

import XCanvas

extension CanvasObject.Identifier {
    static let rectangle = CanvasObject.Identifier("rectangle")
}

class RectangleObject: BaseRectangleObject {
    
    override var identifier: CanvasObject.Identifier? { .rectangle }
    
}

extension RectangleObject: Measurable {
    
    var measurementIdentifier: Int { hashValue }
    
    var measurementTool: MeasurementTool { .rectangle }
    
    var measurementTag: String { tag }
    
    func measurands(pixelLength: CGFloat, unit: Unit) -> [Measurand] {
        guard let size = size else { return [] }
        let w = size.width * pixelLength
        let h = size.height * pixelLength
        let p = w * 2 + h * 2
        return [
            Measurand(type: .width, value: w, unit: unit),
            Measurand(type: .height, value: h, unit: unit),
            Measurand(type: .perimeter, value: p, unit: unit),
            Measurand(type: .area, value: w * h, unit: unit),
        ]
    }
    
}

