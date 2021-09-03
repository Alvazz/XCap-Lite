//
//  TextEditor.swift
//  XCap
//
//  Created by chen on 2021/5/19.
//

import Cocoa

class TextEditor {
    
    private let viewController: TextEditorViewController
    private let sheetWindow: NSWindow
    private let size = CGSize(width: 300, height: 240)
    
    var text: String {
        get { viewController.textView.string }
        set { viewController.textView.string = newValue }
    }
    
    init(text: String = "") {
        viewController = TextEditorViewController.instantiate(from: .panel)
        sheetWindow = NSWindow(contentViewController: viewController)
        sheetWindow.setContentSize(size)
        sheetWindow.contentMinSize = size
        self.text = text
    }
    
    func beginSheetModel(for window: NSWindow, _ completionHandler: @escaping (NSApplication.ModalResponse) -> Void) {
        window.beginSheet(sheetWindow, completionHandler: completionHandler)
    }
    
}
