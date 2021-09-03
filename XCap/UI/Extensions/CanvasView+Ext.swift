//
//  CanvasView+Ext.swift
//  XCap
//
//  Created by scchn on 2021/7/9.
//

import Foundation

import XCanvas

fileprivate extension MeasurementTool {
    
    var prefix: String? {
        switch self {
        case .lineSegment: return "L"
        case .polyline:    return "L"
        case .rectangle:   return "R"
        case .square:      return "S"
        case .polygon:     return "P"
        case .circle:      return "C"
        case .angle:       return "A"
        default:           return nil
        }
    }
    
}

extension CanvasView {
    
    func generateTags() {
        var prefixIDs: [String: Int] = [:]
        
        for object in objects where object.tag.isEmpty {
            guard let measurementTool = MeasurementTool(type(of: object)),
                  let prefix = measurementTool.prefix
            else { continue }
            
            var id = prefixIDs[prefix] ?? 1
            var tag = prefix + "\(id)"
            
            while objects.contains(where: { $0.tag == tag }) {
                id += 1
                tag = prefix + "\(id)"
            }
            
            prefixIDs[prefix] = id
            object.updateTag(tag)
        }
    }
    
}
