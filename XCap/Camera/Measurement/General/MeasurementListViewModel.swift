//
//  MeasurementListViewModel.swift
//  XCap
//
//  Created by scchn on 2021/5/12.
//

import Foundation

import RxSwift
import RxCocoa

extension MeasurementListViewModel {
    
    enum ExportError {
        case noResultsToSave
        case writeFileFailed
    }
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
}

final class MeasurementListViewModel: ViewModelType {
    
    private let uiState: CameraUIState
    
    let sourceID: UUID
    var results: Observable<[MeasurementResult]> { uiState.measurementResults.asObservable() }
    
    init(source: SourceType, uiState: CameraUIState) {
        self.sourceID = source.uuid
        self.uiState = uiState
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
    
}
