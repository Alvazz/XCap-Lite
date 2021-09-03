//
//  CameraSettingsViewModel.swift
//  XCap
//
//  Created by scchn on 2021/4/28.
//

import Foundation

import XCamera
import RxSwift
import RxCocoa

extension CameraSettingsViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
}

final class CameraSettingsViewModel: ViewModelType {
    
    private let source: SourceType
    private let uiState: CameraUIState
    
    lazy private(set)
    var generalViewModel = CameraGeneralSettingsViewModel(source: source, uiState: uiState)
    
    init(source: SourceType, uiState: CameraUIState) {
        self.source = source
        self.uiState = uiState
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
    
}
