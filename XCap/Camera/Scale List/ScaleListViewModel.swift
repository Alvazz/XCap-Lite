//
//  ScaleListViewModel.swift
//  XCap
//
//  Created by scchn on 2021/5/31.
//

import Foundation

import SwiftyUserDefaults
import DifferenceKit
import RxSwift
import RxCocoa

extension ScaleListViewModel {
    
    struct ListItem: Differentiable {
        
        fileprivate var identifier: String
        
        var name: String
        var detail: String
        var isSelected: Bool
        var differenceIdentifier: String { identifier }
        
        func isContentEqual(to source: ListItem) -> Bool {
            name == source.name && detail == source.detail && isSelected == source.isSelected
        }
        
    }
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
}

final class ScaleListViewModel: ViewModelType {
    
    private let uiState: CameraUIState
    
    var listItems: Observable<[ListItem]> {
        let scales = Defaults.rx.value(\.scales)
        let current = uiState.scale
        return Observable.combineLatest(scales, current)
            .map { scales, current in self.getListItems(with: scales, currentScale: current) }
    }
    
    init(uiState: CameraUIState) {
        self.uiState = uiState
    }
    
    private func getListItems(with scales: [Scale], currentScale: Scale?) -> [ListItem] {
        scales.map { scale in
            let id = scale.identifier
            let name = scale.name ?? "-"
            let detail = "H = \(UIHelper.text(scale.fov)) \(scale.unit)"
            let isSelected = scale == currentScale
            return ListItem(identifier: id, name: name, detail: detail, isSelected: isSelected)
        }
    }
    
    func setScale(at index: Int) {
        let scale = Defaults.scales[index]
        uiState.scale.accept(scale)
    }
    
    func deleteScale(at index: Int) {
        Defaults.scales.remove(at: index)
    }
    
    func renameScale(name: String, at index: Int) {
        let scale = Defaults.scales[index]
        Defaults.renameScale(scale: scale, name: name)
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
    
}
