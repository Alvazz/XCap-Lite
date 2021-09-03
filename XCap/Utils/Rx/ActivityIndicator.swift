//
//  ActivityIndicator.swift
//  
//
//  Created by scchn on 2021/4/15.
//

import Cocoa

import RxSwift
import RxCocoa

public class ActivityIndicator: SharedSequenceConvertibleType {
    
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let lock = NSRecursiveLock()
    private let rxBehavior = BehaviorRelay<Bool>(value: false)
    private let rxLoading: SharedSequence<SharingStrategy, Bool>
    
    public init() {
        rxLoading = rxBehavior
            .asDriver()
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<T: ObservableConvertibleType>(_ source: T) -> Observable<T.Element> {
        source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                self.sendStopLoading()
            }, onCompleted: {
                self.sendStopLoading()
            }, onSubscribe: subscribed)
    }
    
    private func subscribed() {
        lock.lock()
        rxBehavior.accept(true)
        lock.unlock()
    }
    
    private func sendStopLoading() {
        lock.lock()
        rxBehavior.accept(false)
        lock.unlock()
    }
    
    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return rxLoading
    }
    
}

extension ObservableConvertibleType {
    
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        activityIndicator.trackActivityOfObservable(self)
    }

}
