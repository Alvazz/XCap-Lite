//
//  CameraListWindowModel.swift
//  XCap
//
//  Created by scchn on 2021/4/21.
//

import Foundation
import AVFoundation

import XCamera
import RxSwift
import RxCocoa

extension CameraListWindowModel {
    
    struct Input {
    }
    
    struct Output {
        var selectedItem: Driver<CameraListItem?>
    }
    
}

class CameraListWindowModel: ViewModelType {
    
    let viewModel: CameraListViewModel
    
    init() {
        self.viewModel = CameraListViewModel()
    }
    
    func transform(_ input: Input) -> Output {
        let selectedItem = viewModel.selectedItem.asDriverOnErrorJustComplete()
        
        return Output(selectedItem: selectedItem)
    }
    
}
