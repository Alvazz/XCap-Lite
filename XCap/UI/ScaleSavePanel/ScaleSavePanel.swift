//
//  ScaleSavePanel.swift
//  XCap
//
//  Created by scchn on 2021/6/1.
//

import Cocoa

class ScaleSavePanel {
    
    private let viewController = ScaleSaveViewController.instantiate(from: .panel)
    private let sheetWindow: NSWindow
    private let size = CGSize(width: 300, height: 142)
    
    var length: CGFloat { viewController.length }
    var unit: Unit { viewController.unit }
    var name: String { viewController.name }
    var save: Bool { viewController.save }
    
    init() {
        sheetWindow = NSWindow(contentViewController: viewController)
        sheetWindow.setContentSize(size)
        sheetWindow.contentMinSize = size
        sheetWindow.contentMaxSize = size
    }
    
    func beginSheetModel(for window: NSWindow, _ completionHandler: @escaping (NSApplication.ModalResponse) -> Void) {
        window.beginSheet(sheetWindow, completionHandler: completionHandler)
    }
    
}
