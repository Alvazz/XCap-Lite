//
//  CameraListViewModel.swift
//  XCap
//
//  Created by scchn on 2021/4/21.
//

import Foundation
import AVFoundation

import XCamera
import RxSwift
import RxCocoa

extension CameraListViewModel {
    
    struct Input {
        var selection: Driver<Int?>
    }
    
    struct Output {
        var items: Driver<[CameraListItem]>
        var selection: Driver<CameraListItem?>
    }
    
}

final class CameraListViewModel: ViewModelType {
    
    private let rxSelectedItem = BehaviorRelay<CameraListItem?>(value: nil)
    
    var selectedItem: Observable<CameraListItem?> { rxSelectedItem.asObservable() }
    
    init() {
        
    }
    
    private func cameraListItems() -> Observable<[CameraListItem]> {
        let center = NotificationCenter.default
        let connection = center.rx.notification(.AVCaptureDeviceWasConnected)
        let disconnection = center.rx.notification(.AVCaptureDeviceWasDisconnected)
        return Observable.of(connection, disconnection).merge()
            .mapToVoid()
            .startWith(())
            .map { _ in
                Camera.videoDevices
                    .map(CameraListItem.init(device:))
                    .sorted { item1, item2 in
                        item1.name < item2.name
                    }
            }
    }
    
    func createCameraWindowModel(cameraListItem: CameraListItem) -> CameraWindowModel? {
        guard let source = CameraSource(uniqueID: cameraListItem.uniqueID) else { return nil }
        return CameraWindowModel(source: source)
    }
    
    func createCameraWindowModel(fileURL: URL) -> CameraWindowModel? {
        guard let source = ImageSource(from: fileURL) else { return nil }
        return CameraWindowModel(source: source)
    }
    
    func transform(_ input: Input) -> Output {
        let items = self.cameraListItems().asDriverOnErrorJustComplete()
        let selection = input.selection.asObservable()
            .withLatestFrom(items) { (selection, items) -> CameraListItem? in
                guard let selection = selection else { return nil }
                return items[selection]
            }
            .do(onNext: rxSelectedItem.accept)
            .asDriverOnErrorJustComplete()
        
        return Output(
            items: items,
            selection: selection
        )
    }
    
}
