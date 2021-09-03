//
//  ImageSource.swift
//  XCap
//
//  Created by scchn on 2021/5/28.
//

import Cocoa

import RxSwift
import RxCocoa

class ImageSource: SourceType {
    
    private let originalImage: NSImage
    private var image: NSImage
    private let _flipOptions = BehaviorRelay<FlipOptions>(value: [])
    
    let uuid: UUID = UUID()
    let name: String
    var dimensions: Observable<CGSize> { .just(image.size) }
    var flipOptions: Observable<FlipOptions> { _flipOptions.asObservable() }
    let previewLayer: CALayer
    
    init(image: NSImage, name: String) {
        self.originalImage = image
        self.image = image
        self.name = name
        self.previewLayer = CALayer()
        
        commonInit()
    }
    
    init?(from fileURL: URL) {
        guard let image = NSImage(contentsOf: fileURL) else { return nil }
        self.originalImage = image
        self.image = image
        self.name = fileURL.lastPathComponent
        self.previewLayer = CALayer()
        
        commonInit()
    }
    
    private func commonInit() {
        previewLayer.contentsGravity = .resizeAspect
        previewLayer.contents = image
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
    
    func applyFlipOptions(_ flipOptions: FlipOptions) {
        image = originalImage.fliped(flipOptions: flipOptions)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer.contents = image
        CATransaction.commit()
        
        _flipOptions.accept(flipOptions)
    }
    
    func capture(_ completionHandler: @escaping (Result<NSImage, SourceError>) -> Void) {
        completionHandler(.success(image))
    }
    
}
