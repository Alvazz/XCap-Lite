//
//  CameraGeneralSettingsViewModel.swift
//  XCap
//
//  Created by scchn on 2021/4/22.
//

import Cocoa
import AVFoundation

import XCamera
import SwiftyUserDefaults
import RxSwift
import RxCocoa

extension CameraGeneralSettingsViewModel {
    
    struct Input {
        var flipHorizontal: Driver<Bool>
        var flipVertical: Driver<Bool>
    }
    
    struct Output {
        struct Camera {
            var formats: Observable<[String]>
            var format: ControlProperty<Int>
            var disconnected: Driver<Void>
        }
        
        var flipHorizontal: Driver<Bool>
        var flipVertical: Driver<Bool>
        var isFlipHorizontal: Driver<Bool>
        var isFlipVertical: Driver<Bool>
        var cameraRelated: Camera?
    }
    
}

final class CameraGeneralSettingsViewModel: ViewModelType {
    
    private let source: SourceType
    private let uiState: CameraUIState
    
    var unit: BehaviorRelay<Unit> { uiState.presentedUnit }
    var backgroundColor: BehaviorRelay<NSColor> { uiState.backgroundColor }
    var showsCrosshair: BehaviorRelay<Bool> { uiState.showsCrosshair }
    var crosshairColor: BehaviorRelay<NSColor> { uiState.crosshairColor }
    var crosshairLineWidth: BehaviorRelay<LineWidth> { uiState.crosshairLineWidth }
    
    init(source: SourceType, uiState: CameraUIState) {
        self.source = source
        self.uiState = uiState
    }
    
    func transform(_ input: Input) -> Output {
        let flipHorizontal = source.flipOptions
            .flatMapLatest { options in
                input.flipHorizontal.do(onNext: { horizontal in
                    horizontal
                        ? self.source.applyFlipOptions(options.union(.horizontal))
                        : self.source.applyFlipOptions(options.subtracting(.horizontal))
                })
            }
            .asDriverOnErrorJustComplete()
        let flipVertical = source.flipOptions
            .flatMapLatest { options in
                input.flipVertical.do(onNext: { vertical in
                    vertical
                        ? self.source.applyFlipOptions(options.union(.vertical))
                        : self.source.applyFlipOptions(options.subtracting(.vertical))
                })
            }
            .asDriverOnErrorJustComplete()
        let isFlipHorizontal = source.flipOptions
            .map { $0.contains(.horizontal) }
            .asDriverOnErrorJustComplete()
        let isFlipVertical = source.flipOptions
            .map { $0.contains(.vertical) }
            .asDriverOnErrorJustComplete()
        let camera: Output.Camera? = {
            guard let source = source as? CameraSource else { return nil }
            return Output.Camera(
                formats: source.formats.map { $0.map(\.localizedName) },
                format: source.activeFormat,
                disconnected: source.disconnect.asDriverOnErrorJustComplete()
            )
        }()
        
        return Output(
            flipHorizontal: flipHorizontal,
            flipVertical: flipVertical,
            isFlipHorizontal: isFlipHorizontal,
            isFlipVertical: isFlipVertical,
            cameraRelated: camera
        )
    }
    
}
