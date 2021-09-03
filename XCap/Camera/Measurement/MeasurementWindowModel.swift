//
//  MeasurementWindowModel.swift
//  XCap
//
//  Created by chen on 2021/6/20.
//

import Foundation

import RxSwift
import RxCocoa

extension MeasurementWindowModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
}

final class MeasurementWindowModel: ViewModelType {
    
    private let source: SourceType
    
    let viewModel: MeasurementViewModel
    var isCameraSource: Bool { source is CameraSource }
    
    init(source: SourceType, uiState: CameraUIState) {
        self.source = source
        viewModel = MeasurementViewModel(source: source, uiState: uiState)
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
    
}
