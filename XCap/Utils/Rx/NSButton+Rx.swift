//
//  NSButton+Rx.swift
//  XCap
//
//  Created by chen on 2021/5/8.
//

import Cocoa

import RxSwift
import RxCocoa

extension Reactive where Base == NSButton {
    
    var on: ControlProperty<Bool> {
        controlProperty(
            getter: { $0.state == .on },
            setter: { $0.state = $1 ? .on : .off }
        )
    }
    
    var toggle: ControlEvent<Bool> {
        let toggle = controlEvent.map { base.state == .on }
        return .init(events: toggle)
    }
    
}
