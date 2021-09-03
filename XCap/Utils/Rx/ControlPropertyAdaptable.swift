//
//  ControlPropertyAdaptable+Rx.swift
//  XCap
//
//  Created by scchn on 2021/6/4.
//

import Cocoa

import RxSwift
import RxCocoa

/// 沒事不要用
protocol ControlPropertyAdaptable: NSObject {}

extension Reactive where Base: ControlPropertyAdaptable {
    
    func value<T>(_ keyPath: KeyPath<Base, T>) -> Observable<T> {
        .create { observer in
            let observation = base.observe(keyPath, options: [.initial, .new]) { object, change in
                observer.onNext(object[keyPath: keyPath])
            }
            return Disposables.create(with: observation.invalidate)
        }
    }
    
    func controlProperty<T>(_ keyPath: WritableKeyPath<Base, T>, _ update: ((Base, T) -> Void)? = nil) -> ControlProperty<T> {
        var emmit = true
        let values = Observable<T>.create { observer in
            let observation = base.observe(keyPath, options: [.initial, .new]) { object, change in
                guard emmit else { return }
                observer.onNext(object[keyPath: keyPath])
            }
            return Disposables.create(with: observation.invalidate)
        }
        let sink = Binder<T>(base) { object, value in
            var state = object
            emmit = false
            state[keyPath: keyPath] = value
            update?(base, value)
            emmit = true
        }
        return ControlProperty(values: values, valueSink: sink)
    }
    
}
