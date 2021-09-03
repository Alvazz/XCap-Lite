//
//  CameraStatusViewModel.swift
//  XCap
//
//  Created by scchn on 2021/5/11.
//

import Cocoa
import AVFoundation

import XCamera
import SwiftyUserDefaults
import RxSwift
import RxCocoa

extension CameraStatusViewModel {
    
    struct ScaleInfo {
        var title: String
        var detail: String
        var isSaved: Bool
    }
    
    struct Input {
        var screen: Driver<NSScreen?>
    }
    
    struct Output {
        struct Camera {
            var recordingBegan: Driver<Void>
            var recordingFinished: Driver<Void>
            var recordingInfo: Driver<(text: String, light: Bool)?>
        }
        
        var magnification: Driver<String>
        var cameraRelated: Camera?
    }
    
}

final class CameraStatusViewModel: ViewModelType {
    
    private let source: SourceType
    private let uiState: CameraUIState
    
    private let rxPreviewSize = BehaviorRelay<CGSize>(value: .zero)
    private let rxRecordingState = BehaviorRelay<(text: String, light: Bool)?>(value: nil)
    private var recordingTimer: Timer?
    
    var scale: Observable<Scale?> { uiState.scale.asObservable() }
    var scaleInfo: Observable<ScaleInfo?> { getScaleInfo() }
    
    init(source: SourceType, uiState: CameraUIState) {
        self.source = source
        self.uiState = uiState
    }
    
    deinit {
        recordingTimer?.invalidate()
    }
    
    func updatePreviewSize(_ size: CGSize) {
        rxPreviewSize.accept(size)
    }
    
    func createScaleListViewModel() -> ScaleListViewModel {
        ScaleListViewModel(uiState: uiState)
    }
    
    // MARK: - Scale Status
    
    private func getScaleInfo() -> Observable<ScaleInfo?> {
        let all = Defaults.rx.value(\.scales)
        let current = uiState.scale
        
        return Observable.combineLatest(all, current)
            .flatMapLatest { (scales, scale) -> Observable<ScaleInfo?> in
                guard let scale = scale else {
                    return .just(nil)
                }
                
                let dimensions = self.source.dimensions
                let unit = self.uiState.presentedUnit
                return Observable.combineLatest(dimensions, unit)
                    .map { dimensions, unit in
                        let h = scale.unit.convert(value: scale.fov, to: unit)
                        let v = h * dimensions.height / dimensions.width
                        
                        let detail = """
                        H = \(UIHelper.text(h)) \(unit)
                        V = \(UIHelper.text(v)) \(unit)
                        """
                        let isSaved = scales.contains(scale)
                        let title = (scales.contains(scale) ? scale.name : nil)
                            ?? "H = \(UIHelper.text(h)) \(unit)"
                        
                        return ScaleInfo(title: title, detail: detail, isSaved: isSaved)
                    }
            }
    }
    
    private func calcMagnification(screen: Driver<NSScreen?>, previewSize: Driver<CGSize>) -> Driver<String> {
        let ratio = source.dimensions.asDriverOnErrorJustComplete()
        let rect = previewSize.map { CGRect(origin: .zero, size: $0) }
        let width = Driver.combineLatest(ratio, rect)
            .map { AVMakeRect(aspectRatio: $0, insideRect: $1).width }
        let fov = uiState.scale
            .map { scale -> CGFloat? in
                guard let scale = scale else { return nil }
                return scale.unit.convert(value: scale.fov, to: .mm)
            }
            .asDriverOnErrorJustComplete()
        
        return Driver.combineLatest(screen, width, fov)
            .map { screen, width, fov in
                guard let fov = fov else { return "" }
                guard let screen = screen else { return "Off-Screen" }
                let multi = screen.physicalSize.width / screen.pixelSize.width
                let magnification = (width / fov) * multi
                return UIHelper.text(magnification) + "X"
            }
    }
    
    func addCurrentScale(with name: String) {
        guard let scale = uiState.scale.value else { return }
        let presentedUnit = uiState.presentedUnit.value
        Defaults.addScale(scale, renameTo: name, unit: presentedUnit)
        uiState.scale.accept(scale)
    }
    
    // MARK: - Recording
    
    private func recordingDidStart() {
        let startDate = Date()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            let elapsedTime = Int(Date().timeIntervalSince(startDate))
            let hours = elapsedTime / 3600
            let minutes = elapsedTime % 3600 / 60
            let seconds = elapsedTime % 60
            let text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            let light = seconds.isMultiple(of: 2)
            self?.rxRecordingState.accept((text, light))
        }
        timer.fire()
        recordingTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func recordingDidFinish() {
        guard let timer = recordingTimer else { return }
        timer.invalidate()
        recordingTimer = nil
        rxRecordingState.accept(nil)
    }
    
    func transform(_ input: Input) -> Output {
        let magnification = calcMagnification(screen: input.screen, previewSize: rxPreviewSize.asDriver())
        let camera: Output.Camera? = {
            guard let source = source as? CameraSource else { return nil }
            let recordingBegan = source.recordingBegan
                .mapToVoid()
                .do(onNext: recordingDidStart)
            let recordingFinished = source.recordingFinished
                .mapToVoid()
                .do(onNext: recordingDidFinish)
            return Output.Camera(
                recordingBegan: recordingBegan.asDriverOnErrorJustComplete(),
                recordingFinished: recordingFinished.asDriverOnErrorJustComplete(),
                recordingInfo: rxRecordingState.asDriverOnErrorJustComplete()
            )
        }()
        
        return Output(
            magnification: magnification,
            cameraRelated: camera
        )
    }
    
}
