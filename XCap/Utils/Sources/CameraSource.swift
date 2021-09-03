//
//  CameraSource.swift
//  XCap
//
//  Created by scchn on 2021/5/28.
//

import Cocoa
import AVFoundation

import XCamera
import RxSwift
import RxCocoa

class CameraSource: SourceType {
    
    private let camera: Camera
    private let _flipOptions = BehaviorRelay<FlipOptions>(value: [])
    
    let uuid: UUID = UUID()
    var name: String {
        #if DEMO_MODE
        return "Digital Microscope"
        #else
        return camera.name
        #endif
    }
    var dimensions: Observable<CGSize> { camera.rx.activeFormat.map(\.dimensions) }
    var flipOptions: Observable<FlipOptions> { _flipOptions.asObservable() }
    
    lazy private(set)
    var previewLayer: CALayer = camera.createPreviewLayer()
    
    init?(uniqueID: String) {
        guard let device = AVCaptureDevice(uniqueID: uniqueID),
              let camera = try? Camera(device: device)
        else { return nil }
        // init
        self.camera = camera
        // Flip
        let defaultFlip = FlipOptions(rawValue: camera.flipOptions.rawValue)
        _flipOptions.accept(defaultFlip)
    }
    
    func start() {
        camera.startRunning()
    }
    
    func stop() {
        camera.stopRunning()
    }
    
    func applyFlipOptions(_ flipOptions: FlipOptions) {
        camera.flipOptions = XCamera.FlipOptions(rawValue: flipOptions.rawValue)
        _flipOptions.accept(flipOptions)
    }
    
    func capture(_ completionHandler: @escaping (Result<NSImage, SourceError>) -> Void) {
        camera.capture { result in
            guard let pixelBuffer = try? result.get(),
                  let image = NSImage(pixelBuffer: pixelBuffer)
            else {
                completionHandler(.failure(.captureFailed))
                return
            }
            completionHandler(.success(image))
        }
    }
    
    // MARK: - Camera
    
    // Format
    var formats: Observable<[AVCaptureDevice.Format]> {
        .just(camera.formats)
    }
    var activeFormat: ControlProperty<Int> {
        let values = camera.rx.activeFormat.map { format in
            self.camera.formats.firstIndex(of: format) ?? -1
        }
        let sink = Binder<Int>(camera) { camera, index in
            let format = camera.formats[index]
            guard format != camera.activeFormat else { return }
            camera.setFormat(format)
        }
        return ControlProperty(values: values, valueSink: sink)
    }
    // Recording
    var isRecording: Observable<Bool> {
        camera.rx.isRecording
    }
    var recordingBegan: Observable<URL> {
        camera.rx.startRecording
    }
    var recordingFinished: Observable<(URL, Error?)> {
        camera.rx.finishRecording
    }
    // Disconnection
    var disconnect: Observable<Void> {
        camera.rx.disconnect
    }
    
    func toggleRecording() -> Bool {
        if camera.isRecording {
            camera.stopRecording()
            return true
        } else {
            return camera.startRecording()
        }
    }
    
}
