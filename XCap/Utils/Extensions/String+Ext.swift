//
//  String+Ext.swift
//  XCap
//
//  Created by chen on 2021/5/22.
//

import Foundation

enum LocalizationTable {
    case `default`
    case Models
    
    fileprivate var tableName: String? {
        switch self {
        case .default: return nil
        case .Models:  return "Models"
        }
    }
    
}

extension String {
    
    func localized(table: LocalizationTable = .default) -> String {
        NSLocalizedString(self, tableName: table.tableName, value: "<Key=\(self)>", comment: "")
    }
    
    func localized(table: LocalizationTable = .default, _ arguments: CVarArg...) -> String {
        String(
            format: localized(table: table),
            arguments: arguments
        )
    }
    
    func ifEmpty(_ alt: String) -> String {
        isEmpty ? alt : self
    }
    
}
