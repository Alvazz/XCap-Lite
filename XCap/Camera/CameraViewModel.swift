//
//  CameraViewModel.swift
//  XCap
//
//  Created by chen on 2021/4/22.
//

import AppKit
import AVFoundation

import XCanvas
import XCamera
import SwiftyUserDefaults
import RxSwift
import RxCocoa

extension CameraViewModel {
    
    struct Input {
        var previewBounds: Driver<CGRect>
        var updateMeasurements: Driver<[Measurable]>
    }
    
    struct Output {
        var previewSize: Driver<CGSize>
        var updateMeasurements: Driver<Void>
        var disconnect: Driver<Void>
    }
    
}

class CameraViewModel: ViewModelType {
    
    private let source: SourceType
    private let uiState: CameraUIState
    
    private(set) lazy
    var settingsViewModel = CameraSettingsViewModel(source: source, uiState: uiState)
    
    private(set) lazy
    var statusViewModel = CameraStatusViewModel(source: source, uiState: uiState)
    
    private(set) lazy
    var previewLayer = source.previewLayer
    
    var sourceID: UUID { source.uuid }
    
    var backgroundColor: Observable<NSColor> { uiState.backgroundColor.asObservable() }
    var dimensions: Observable<CGSize> { source.dimensions }
    var flipOptions: Observable<FlipOptions> { source.flipOptions }
    // Crosshair
    var showsCrosshair: Observable<Bool> { uiState.showsCrosshair.asObservable() }
    var crosshairColor: Observable<NSColor> { uiState.crosshairColor.asObservable() }
    var crosshairLineWidth: Observable<CGFloat> { uiState.crosshairLineWidth.map(\.width) }
    // Canvas
    var strokeColor: BehaviorRelay<NSColor> { uiState.strokeColor }
    var fillColor: BehaviorRelay<NSColor> { uiState.fillColor }
    var lineWidth: BehaviorRelay<LineWidth> { uiState.lineWidth }
    var textColor: BehaviorRelay<NSColor> { uiState.textColor }
    var textSize: BehaviorRelay<CGFloat> { uiState.textSize }
    // Tag
    var automaticallyHideTags: BehaviorRelay<Bool> { uiState.automaticallyHideTags }
    // Capture
    var snapshotFileFormat: BehaviorRelay<ImageFileFormat> { uiState.snapshotFileFormat }
    var snapshotWithGraphics: BehaviorRelay<Bool> { uiState.snapshotWithGraphics }
    var snapshotWithTags: BehaviorRelay<Bool> { uiState.snapshotWithTags }
    
    init(source: SourceType, uiState: CameraUIState) {
        self.source = source
        self.uiState = uiState
    }
    
    // MARK: - Capture
    
    func capture(_ completionHandler: @escaping (Result<NSImage, SourceError>) -> Void) {
        source.capture(completionHandler)
    }
    
    // MARK: - Calibration
    
    func calibrate(with scale: Scale, save: Bool) {
        uiState.scale.accept(scale)
        uiState.presentedUnit.accept(scale.unit)
        if save && !Defaults.scales.contains(scale) {
            Defaults.scales.append(scale)
        }
    }
    
    func transform(_ input: Input) -> Output {
        let previewSize = previewSize(bounds: input.previewBounds.asObservable())
            .do(onNext: statusViewModel.updatePreviewSize(_:))
            .asDriverOnErrorJustComplete()
        
        let measurables = input.updateMeasurements.asObservable()
        let updateMeasurements = updateMeasurementResults(measurables: measurables)
            .asDriverOnErrorJustComplete()
        
        let disconnect = ((source as? CameraSource)?.disconnect ?? .empty())
            .asDriverOnErrorJustComplete()
        
        return Output(
            previewSize: previewSize,
            updateMeasurements: updateMeasurements,
            disconnect: disconnect
        )
    }
    
}

extension CameraViewModel {
    
    private func previewSize(bounds: Observable<CGRect>) -> Observable<CGSize> {
        let dimensions = source.dimensions
        let displayMode = uiState.displayMode
        
        return displayMode
            .flatMapLatest { magnifierSize -> Observable<CGSize> in
                if let scale = magnifierSize.scaleFactor {
                    return dimensions.map { dimensions in
                        dimensions.applying(.init(scaleX: scale, y: scale))
                    }
                } else {
                    return bounds.map(\.size)
                }
            }
    }
    
    private func updateMeasurementResults(measurables: Observable<[Measurable]>) -> Observable<Void> {
        let width = source.dimensions.map(\.width)
        let scale = uiState.scale
        let unit = uiState.presentedUnit
        let updateMeasurements = Observable.combineLatest(measurables, width, scale, unit)
            .do(onNext: { (measurables, width, scale, unit) in
                let pixelLength: CGFloat = {
                    guard let scale = scale else { return 0 }
                    let fov = scale.unit.convert(value: scale.fov, to: unit)
                    return fov / width
                }()
                let results = measurables.compactMap { measurable in
                    MeasurementResult(measurable: measurable, pixelLength: pixelLength, unit: unit)
                }
                self.uiState.measurementResults.accept(results)
            })
            .mapToVoid()
        
        return updateMeasurements
    }
    
}
