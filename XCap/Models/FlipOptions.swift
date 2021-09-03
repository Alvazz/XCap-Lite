//
//  FlipOptions.swift
//  XCap
//
//  Created by chen on 2021/6/11.
//

import Foundation

struct FlipOptions: OptionSet {
    
    var rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let `default`  = FlipOptions()
    static let horizontal = FlipOptions(rawValue: 1 << 0)
    static let vertical   = FlipOptions(rawValue: 1 << 1)
    
}
