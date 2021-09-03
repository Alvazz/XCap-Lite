//
//  NSColoeWell+Rx.swift
//  XCap
//
//  Created by scchn on 2021/5/11.
//

import Cocoa

import RxSwift
import RxCocoa

extension Reactive where Base == NSColorWell {
    
    var color: ControlProperty<NSColor> {
        controlProperty(
            getter: { $0.color },
            setter: { $0.color = $1 }
        )
    }
    
}
