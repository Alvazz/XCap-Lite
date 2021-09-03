//
//  MeasurementTool.swift
//  XCap
//
//  Created by scchn on 2021/4/29.
//

import Cocoa

import XCanvas

enum MeasurementTool: String, CaseIterable, CustomStringConvertible {
    
    case lineSegment
    case polyline
    case rectangle
    case square
    case polygon
    case circle
    case angle
    case textbox
    case pencil
    
    init?(_ type: CanvasObject.Type) {
        switch type {
        case is LineObject.Type:      self = .lineSegment
        case is PolylineObject.Type:  self = .polyline
        case is RectangleObject.Type: self = .rectangle
        case is SquareObject.Type:    self = .square
        case is PolygonObject.Type:   self = .polygon
        case is CircleObject.Type:    self = .circle
        case is AngleObject.Type:     self = .angle
        case is TextboxObject.Type:   self = .textbox
        case is PencilObject.Type:    self = .pencil
        default:                      return nil
        }
    }
    
    var index: Int { Self.allCases.firstIndex(of: self)! }
    
    var id: CanvasObject.Identifier { .init(rawValue) }
    
    var description: String {
        "MeasurementTool.\(rawValue)".localized(table: .Models)
    }
    
    var toolTip: String {
        "MeasurementTool.\(rawValue).toolTip".localized(table: .Models)
    }
    
    var image: NSImage {
        switch self {
        case .lineSegment: return #imageLiteral(resourceName: "line")
        case .polyline:    return #imageLiteral(resourceName: "polyline")
        case .rectangle:   return #imageLiteral(resourceName: "rectangle")
        case .square:      return #imageLiteral(resourceName: "square")
        case .polygon:     return #imageLiteral(resourceName: "polygon")
        case .circle:      return #imageLiteral(resourceName: "circle")
        case .angle:       return #imageLiteral(resourceName: "angle")
        case .textbox:     return #imageLiteral(resourceName: "textbox")
        case .pencil:      return #imageLiteral(resourceName: "pencil")
        }
    }
    
}

extension MeasurementTool: CanvasObjectTypeConvertible {
    
    var objectType: CanvasObject.Type {
        switch self {
        case .lineSegment: return LineObject.self
        case .polyline:    return PolylineObject.self
        case .rectangle:   return RectangleObject.self
        case .square:      return SquareObject.self
        case .polygon:     return PolygonObject.self
        case .circle:      return CircleObject.self
        case .angle:       return AngleObject.self
        case .textbox:     return TextboxObject.self
        case .pencil:      return PencilObject.self
        }
    }
    
    init?(identifier: CanvasObject.Identifier) {
        self.init(rawValue: identifier.rawValue)
    }
    
}
