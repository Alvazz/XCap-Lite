//
//  ViewModelType.swift
//  XCap
//
//  Created by chen on 2021/4/21.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
