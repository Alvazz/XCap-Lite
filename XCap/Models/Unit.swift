//
//  Unit.swift
//  XCap
//
//  Created by scchn on 2021/5/7.
//

import Foundation

@objc
enum Unit: Int, CaseIterable, CustomStringConvertible, Codable {
    
    case cm
    case mm
    case um
    case inch
    case mil
        
    var description: String {
        switch self {
        case .cm:   return "cm"
        case .mm:   return "mm"
        case .um:   return "um"
        case .inch: return "inch"
        case .mil:  return "mil"
        }
    }
    
    var unitLength: UnitLength {
        switch self {
        case .cm:   return .centimeters
        case .mm:   return .millimeters
        case .um:   return .micrometers
        case .inch: return .inches
        case .mil:  return .mil
        }
    }
    
    func convert(value: CGFloat, to unit: Unit) -> CGFloat {
        let m = Measurement(value: Double(value), unit: unitLength)
        return CGFloat(m.converted(to: unit.unitLength).value)
    }
    
}

extension UnitLength {
    
    static var mil: UnitLength {
        let converter = UnitConverterLinear(coefficient: 2.54e-5, constant: 0)
        return UnitLength(symbol: "mil", converter: converter)
    }
    
}
