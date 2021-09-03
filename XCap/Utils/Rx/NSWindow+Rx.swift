//
//  NSWindow+Rx.swift
//  XCap
//
//  Created by chen on 2021/5/11.
//

import Cocoa

import RxSwift

extension Reactive where Base == NSWindow {
    
    var screen: Observable<NSScreen?> {
        NotificationCenter.default.rx
            .notification(NSWindow.didChangeScreenNotification, object: base)
            .map { ($0.object as? NSWindow)?.screen }
            .startWith(base.screen)
    }
    
}
