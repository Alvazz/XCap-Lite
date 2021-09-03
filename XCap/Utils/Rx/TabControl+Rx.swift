//
//  TabControl+Rx.swift
//  XCap
//
//  Created by scchn on 2021/7/28.
//

import Cocoa

import RxSwift
import RxCocoa

extension Reactive where Base == TabControl {
    
    var indexOfSelectedTab: ControlProperty<Int> {
        base.rx.controlProperty(
            getter: { $0.indexOfSelectedTab },
            setter: { $0.selectTab(at: $1) }
        )
    }
    
}
