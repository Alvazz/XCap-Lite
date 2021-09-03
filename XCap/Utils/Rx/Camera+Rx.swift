//
//  Camera+Rx.swift
//  XCap
//
//  Created by scchn on 2021/4/22.
//

import Foundation
import AVFoundation

import XCamera
import RxSwift
import RxCocoa

extension Camera: ReactiveCompatible {
    
}

extension Reactive where Base == Camera {
    
    private var proxy: CameraDelegateProxy { .proxy(for: base) }
    
    var disconnect: Observable<Void> { proxy.disconnect.asObservable() }
    var activeFormat: Observable<AVCaptureDevice.Format> { proxy.format.asObservable() }
    var startRecording: Observable<URL> { proxy.startRecording.asObservable() }
    var finishRecording: Observable<(URL, Error?)> { proxy.finishRecording.asObservable() }
    var isRecording: Observable<Bool> { proxy.isRecording.asObservable() }
    
}

fileprivate class CameraDelegateProxy: DelegateProxy<Camera, CameraDelegate>, DelegateProxyType {
    
    let disconnect: PublishRelay<Void>
    let format: BehaviorRelay<AVCaptureDevice.Format>
    let startRecording = PublishRelay<URL>()
    let finishRecording = PublishRelay<(URL, Error?)>()
    let isRecording = BehaviorRelay<Bool>(value: false)
    
    init(camera: Camera) {
        disconnect = .init()
        format = .init(value: camera.activeFormat)
        
        super.init(parentObject: camera, delegateProxy: CameraDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        register(make: CameraDelegateProxy.init)
    }
    
    static func currentDelegate(for object: Camera) -> CameraDelegate? {
        object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: CameraDelegate?, to object: Camera) {
        object.delegate = delegate
    }
        
}

extension CameraDelegateProxy: CameraDelegate {
    
    func cameraWasDisconnected(_ camera: Camera) {
        disconnect.accept(())
    }
    
    func camera(_ camera: Camera, formatDidChange format: AVCaptureDevice.Format) {
        self.format.accept(format)
    }
    
    func camera(_ camera: Camera, frameRateRangeDidChange range: AVFrameRateRange) {
        
    }
    
    func camera(_ camera: Camera, recordingStateDidChange state: Camera.RecordingState) {
        switch state {
        case let .began(url):
            isRecording.accept(true)
            startRecording.accept(url)
        case let .finished(url, error):
            isRecording.accept(false)
            finishRecording.accept((url, error))
        default:
            break
        }
    }
    
}
