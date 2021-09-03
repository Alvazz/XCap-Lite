//
//  ErrorTracker.swift
//  
//
//  Created by scchn on 2021/4/15.
//

import Foundation

import RxSwift
import RxCocoa

public class ErrorTracker: SharedSequenceConvertibleType {
    
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let subject: PublishSubject<Error>
    
    public init() {
        subject = .init()
    }
    
    deinit {
        subject.onCompleted()
    }

    public func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        source
            .asObservable()
            .do(onError: onError)
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
        subject.asDriverOnErrorJustComplete()
    }

    public func asObservable() -> Observable<Error> {
        subject
    }

    private func onError(_ error: Error) {
        subject.onNext(error)
    }
}

extension ObservableConvertibleType {
    
    public func trackError(_ errorTracker: ErrorTracker) -> Observable<Element> {
        return errorTracker.trackError(from: self)
    }

}
