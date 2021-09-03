//
//  SourceType.swift
//  XCap
//
//  Created by scchn on 2021/5/28.
//

import Cocoa

import RxSwift

enum SourceError: LocalizedError {
    case captureFailed
    
    var errorDescription: String? {
        switch self {
        case .captureFailed: return "SourceError.captureFailed".localized()
        }
    }
}

protocol SourceType: AnyObject {
    
    var uuid: UUID { get }
    var name: String { get }
    var dimensions: Observable<CGSize> { get }
    var flipOptions: Observable<FlipOptions> { get }
    var previewLayer: CALayer { get }
    
    func start()
    func stop()
    func applyFlipOptions(_ flipOptions: FlipOptions)
    func capture(_ completionHandler: @escaping (Result<NSImage, SourceError>) -> Void)
    
}
