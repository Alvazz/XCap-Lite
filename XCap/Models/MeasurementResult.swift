//
//  Measurable.swift
//  XCap
//
//  Created by scchn on 2021/5/12.
//

import Foundation

import XCanvas
import DifferenceKit

struct Measurand: Equatable, Hashable {
    
    enum ValueType: String, CaseIterable {
        case length
        case width, height, perimeter
        case radius, diameter, circumference
        case angle, angle1, angle2
        case area
        case sum
        
        var description: String { "Measurand.\(rawValue)".localized(table: .Models) }
    }
    
    var type: ValueType
    var value: CGFloat
    var unit: Unit
    
    func unitDescriptionByType() -> String {
        switch type {
        case .angle, .angle1, .angle2:
            return "°"
            
        case .area:
            return unit.description + "²"
            
        default:
            return unit.description
        }
    }
    
}

protocol Measurable {
    var measurementIdentifier: Int { get }
    var measurementTool: MeasurementTool { get }
    var measurementTag: String { get }
    
    func measurands(pixelLength: CGFloat, unit: Unit) -> [Measurand]
}

struct MeasurementResult: Equatable, Hashable {
    
    var identifier: Int
    var tag: String
    var measurementTool: MeasurementTool
    var measurands: [Measurand]
    
    init?(measurable: Measurable, pixelLength: CGFloat, unit: Unit) {
        self.identifier      = measurable.measurementIdentifier
        self.tag             = measurable.measurementTag
        self.measurementTool = measurable.measurementTool
        self.measurands      = measurable.measurands(pixelLength: pixelLength, unit: unit)
    }
    
}

extension MeasurementResult: Differentiable {
    var differenceIdentifier: Int { identifier }
}
