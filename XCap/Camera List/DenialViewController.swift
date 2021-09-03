//
//  DenialViewController.swift
//  XCap
//
//  Created by scchn on 2021/5/27.
//

import Cocoa

class DenialViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = UIConst.Main.contentSize
    }
    
    @IBAction func quitButtonAction(_ sender: Any) {
        NSApp.terminate(nil)
    }
    
    @IBAction func preferencesButtonAction(_ sender: Any) {
        let prefsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!
        NSWorkspace.shared.open(prefsURL)
    }
    
}
