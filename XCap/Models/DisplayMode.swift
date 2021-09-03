//
//  DisplayMode.swift
//  XCap
//
//  Created by scchn on 2021/5/21.
//

import Foundation

@objc
enum DisplayMode: Int, CaseIterable, CustomStringConvertible {
    
    case fillWindow
    case actualSize
    /// 125%
    case mode1
    /// 150%
    case mode2
    /// 175%
    case mode3
    /// 200%
    case mode4
    
    var scaleFactor: CGFloat? {
        switch self {
        case .fillWindow: return nil
        case .actualSize: return 1
        case .mode1:      return 1.25
        case .mode2:      return 1.5
        case .mode3:      return 1.75
        case .mode4:      return 2
        }
    }
    
    var description: String {
        switch self {
        case .fillWindow: return "DisplayMode.Fill".localized(table: .Models)
        case .actualSize: return "DisplayMode.Actual_Size".localized(table: .Models)
        case .mode1:      return "DisplayMode.Mode1".localized(table: .Models)
        case .mode2:      return "DisplayMode.Mode2".localized(table: .Models)
        case .mode3:      return "DisplayMode.Mode3".localized(table: .Models)
        case .mode4:      return "DisplayMode.Mode4".localized(table: .Models)
        }
    }
    
}
