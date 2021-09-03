//
//  UIConst.swift
//  XCap
//
//  Created by scchn on 2021/4/28.
//

import Foundation

struct UIConst {
    
    struct Main {
        static let contentSize = CGSize(width: 500, height: 248)
        static let rowHeight: CGFloat = 44
    }
    
    struct Camera {
        static let contentSize: CGSize = {
            let multi  = CGFloat(58)
            let width  = multi * 16
            let height = multi * 9
            return CGSize(width: 32 + 1 + width, height: 32 + 1 + height + 1 + 32)
        }()
        
        static let lineWidthRange: ClosedRange<CGFloat> = 1...3
        
        static let settingsWidth: CGFloat = 320
        
        struct ScaleList {
            static let rowHeight: CGFloat = 32
        }
        
        struct Measurement {
            static let contentSize = CGSize(width: 400, height: 400)
            static let rowHeight: CGFloat = 32
        }
    }
    
}

struct UIHelper {
    
    static func text(_ value: CGFloat) -> String {
        let newValue = round(value * 1000) / 1000
        return newValue.description
    }
    
}
