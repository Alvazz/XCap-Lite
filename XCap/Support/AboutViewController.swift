//
//  AboutViewController.swift
//  XCap
//
//  Created by scchn on 2021/5/25.
//

import Cocoa

class AboutViewController: NSViewController {
    
    @IBOutlet weak var versionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.stringValue = "v" + version
        } else {
            versionLabel.stringValue = "v1.0"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func contectButtonAction(_ sender: Any) {
        let url = URL(string: "https://github.com/scchn")!
        NSWorkspace.shared.open(url)
    }
    
}
