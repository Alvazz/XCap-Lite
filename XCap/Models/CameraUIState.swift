//
//  CameraUIState.swift
//  XCap
//
//  Created by scchn on 2021/5/10.
//

import Cocoa

import XCanvas
import SwiftyUserDefaults
import RxSwift
import RxCocoa

class CameraUIState {
    
    private var observers: [NSObjectProtocol] = []
    
    init() {
        setupObservers()
    }
    
    deinit {
        observers.forEach(NotificationCenter.default.removeObserver(_:))
    }
    
    private func setupObservers() {
        let center = NotificationCenter.default
        let renameNotificationName = DefaultsAdapter.didRenameScaleNotification
        let rename = center.addObserver(forName: renameNotificationName, object: nil, queue: .main) { [weak self] notification in
            guard let self = self,
                  let scaleID = notification.object as? String, self.scale.value?.identifier == scaleID ,
                  let scale = Defaults.scales.first(where: { $0.identifier == scaleID })
            else { return }
            self.scale.accept(scale)
        }
        observers.append(rename)
    }
    
    convenience init(from state: CameraUIState) {
        self.init()
        // Preview
        backgroundColor.accept(state.backgroundColor.value)
        showsCrosshair.accept(state.showsCrosshair.value)
        crosshairColor.accept(state.crosshairColor.value)
        crosshairLineWidth.accept(state.crosshairLineWidth.value)
        strokeColor.accept(state.strokeColor.value)
        fillColor.accept(state.fillColor.value)
        lineWidth.accept(state.lineWidth.value)
        textColor.accept(state.textColor.value) 
        textSize.accept(state.textSize.value) 
        // Measurement
        scale.accept(state.scale.value)
        presentedUnit.accept(state.presentedUnit.value)
    }
    
    // MARK: - Preview
    
    let displayMode           = BehaviorRelay<DisplayMode>(value: .fillWindow)
    let backgroundColor       = BehaviorRelay<NSColor>(value: .black)
    let showsCrosshair        = BehaviorRelay<Bool>(value: false )
    let crosshairColor        = BehaviorRelay<NSColor>(value: .black)
    let crosshairLineWidth    = BehaviorRelay<LineWidth>(value: .width1)
    let strokeColor           = BehaviorRelay<NSColor>(value: .black)
    let fillColor             = BehaviorRelay<NSColor>(value: .white)
    let lineWidth             = BehaviorRelay<LineWidth>(value: .width1)
    let textColor             = BehaviorRelay<NSColor>(value: .black)
    let textSize              = BehaviorRelay<CGFloat>(value: 13)
    let automaticallyHideTags = BehaviorRelay<Bool>(value: true)
    
    // MARK: - Capture
    
    let snapshotFileFormat   = BehaviorRelay<ImageFileFormat>(value: .png)
    let snapshotWithGraphics = BehaviorRelay<Bool>(value: true)
    let snapshotWithTags     = BehaviorRelay<Bool>(value: true)
    
    // MARK: - Measurement
    
    let scale = BehaviorRelay<Scale?>(value: nil)
    let presentedUnit = BehaviorRelay<Unit>(value: .cm)
    
    let measurementResults = BehaviorRelay<[MeasurementResult]>(value: [])
    
}
