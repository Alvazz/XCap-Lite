//
//  TextEditorViewController.swift
//  XCap
//
//  Created by chen on 2021/5/18.
//

import Cocoa

class TextEditorViewController: NSViewController {
    
    @IBOutlet var textView: NSTextView!
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        guard let window = view.window else { return }
        window.sheetParent?.endSheet(window, returnCode: .cancel)
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        guard let window = view.window else { return }
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }
    
}
