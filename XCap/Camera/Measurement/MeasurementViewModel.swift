//
//  MeasurementViewModel.swift
//  XCap
//
//  Created by chen on 2021/6/20.
//

import Foundation

import RxSwift
import RxCocoa

extension MeasurementViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
}

final class MeasurementViewModel: ViewModelType {
    
    let measurementListViewModel: MeasurementListViewModel

    init(source: SourceType, uiState: CameraUIState) {
        measurementListViewModel = MeasurementListViewModel(source: source, uiState: uiState)
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
    
}
