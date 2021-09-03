//
//  Circular.swift
//  XCap
//
//  Created by chen on 2021/5/30.
//

import Foundation

import XCanvas

protocol Circular: Measurable {
    var center: CGPoint { get }
    var radius: CGFloat { get }
}

extension Circular {
    
    func measurands(pixelLength: CGFloat, unit: Unit) -> [Measurand] {
        guard center != .zero && radius > 0 else { return [] }
        
        let radius = radius * pixelLength
        let diameter = radius * 2
        let circumference = .pi * radius * 2
        let area = .pi * radius * radius
        
        return [
            Measurand(type: .radius, value: radius, unit: unit),
            Measurand(type: .diameter, value: diameter, unit: unit),
            Measurand(type: .circumference, value: circumference, unit: unit),
            Measurand(type: .area, value: area, unit: unit),
        ]
    }
    
}
