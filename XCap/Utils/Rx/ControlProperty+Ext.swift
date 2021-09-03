//
//  ControlProperty+Ext.swift
//  XCap
//
//  Created by scchn on 2021/5/21.
//

import Foundation

import RxSwift
import RxCocoa

extension ControlProperty {
    
    func mapToRawValue() -> ControlProperty<Element.RawValue> where Element: RawRepresentable {
        let values = asObservable().map(\.rawValue)
        let sink = AnyObserver<Element.RawValue> { event in
            guard case .next(let rawValue) = event,
                  let value = Element(rawValue: rawValue)
            else { return }
            self.onNext(value)
        }
        return ControlProperty<Element.RawValue>(values: values, valueSink: sink)
    }
    
}
