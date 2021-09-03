//
//  CameraWindowModel.swift
//  XCap
//
//  Created by chen on 2021/4/21.
//

import AppKit
import AVFoundation

import XCamera
import RxSwift
import RxCocoa

extension CameraWindowModel {
    
    struct Input {
        
    }
    
    struct Output {
        struct Camera {
            var isRecording: Driver<Bool>
            var recordingBegan: Driver<Void>
            var recordingFinished: Driver<URL>
            var disconnected: Driver<Void>
        }
        
        var cameraRelated: Camera?
    }
    
}

class CameraWindowModel: ViewModelType {
    
    private let source: SourceType
    private let uiState: CameraUIState
    private var lastVideoFielURL: URL?
    
    let viewModel: CameraViewModel
    
    private(set) lazy
    var measurementWindowModel = MeasurementWindowModel(source: source, uiState: uiState)
    
    var title: String {
        source is ImageSource
            ? "Image.Title_Format".localized(source.name)
            : "Camera.Title_Format".localized(source.name)
    }
    var isCameraSource: Bool { source is CameraSource }
    var displayMode: BehaviorRelay<DisplayMode> { uiState.displayMode }
    var automaticallyHideTags: BehaviorRelay<Bool> { uiState.automaticallyHideTags }
    
    init(source: SourceType, uiState: CameraUIState = .init()) {
        self.source = source
        self.uiState = uiState
        self.viewModel = CameraViewModel(source: source, uiState: uiState)
        //
        source.start()
    }
    
    deinit {
        source.stop()
        if let url = lastVideoFielURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func createCameraWinowModelWithSnapshot(_ completionHandler: @escaping (Result<CameraWindowModel, SourceError>) -> Void) {
        source.capture { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(image):
                let source = ImageSource(image: image, name: self.source.name)
                let state = CameraUIState(from: self.uiState)
                let windowModel = CameraWindowModel(source: source, uiState: state)
                completionHandler(.success(windowModel))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func toggleRecording() -> Bool {
        guard let source = source as? CameraSource else { return false }
        return source.toggleRecording()
    }
    
    func transform(_ input: Input) -> Output {
        let camera: Output.Camera? = {
            guard let source = source as? CameraSource else { return nil }
            let began = source.recordingBegan.do(onNext: { self.lastVideoFielURL = $0 })
            let finished = source.recordingFinished.map(\.0)
            return Output.Camera(
                isRecording: source.isRecording.asDriverOnErrorJustComplete(),
                recordingBegan: began.mapToVoid().asDriverOnErrorJustComplete(),
                recordingFinished: finished.asDriverOnErrorJustComplete(),
                disconnected: source.disconnect.asDriverOnErrorJustComplete()
            )
        }()
        
        return Output(
            cameraRelated: camera
        )
    }
    
}
