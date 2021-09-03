//
//  DefaultsAdapter+Rx.swift
//  XCap
//
//  Created by scchn on 2021/5/31.
//

import Foundation

import SwiftyUserDefaults
import RxSwift

extension DefaultsAdapter: ReactiveCompatible {}

extension Reactive where Base == DefaultsAdapter<DefaultsKeys> {
    
    func value<T: DefaultsSerializable>(_ keyPath: KeyPath<DefaultsKeys, DefaultsKey<T>>)
    -> Observable<T> where T == T.T {
        Observable.create { observer in
            let disposable = self.base.observe(keyPath, options: [.initial, .new]) { update in
                guard let newValue = update.newValue else { return }
                observer.onNext(newValue)
            }
            return Disposables.create(with: disposable.dispose)
        }
    }

}
