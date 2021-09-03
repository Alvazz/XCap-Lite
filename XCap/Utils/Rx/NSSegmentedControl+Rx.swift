//
//  NSSegmentedControl+Rx.swift
//  XCap
//
//  Created by chen on 2021/7/2.
//

import Cocoa

import RxSwift
import RxCocoa

extension Reactive where Base == NSSegmentedControl {
    
    var selectedSegment: ControlProperty<Int> {
        base.rx.controlProperty(
            getter: { $0.indexOfSelectedItem },
            setter: { $0.selectedSegment = $1 }
        )
    }
    
    var select: ControlEvent<Int> {
        let select = controlEvent.map { base.selectedSegment }
        return .init(events: select)
    }
    
}
