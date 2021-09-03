//
//  ScaleSaveViewController.swift
//  XCap
//
//  Created by scchn on 2021/6/1.
//

import Cocoa

class ScaleSaveViewController: NSViewController {
    
    @IBOutlet weak var unitPopUpButton: NSPopUpButton!
    @IBOutlet weak var lengthTextField: NSTextField!
    @IBOutlet weak var saveCheckbox: NSButton!
    @IBOutlet weak var nameTextField: NSTextField!
    
    var length: CGFloat { CGFloat(Double(lengthTextField.stringValue) ?? 0) }
    var unit: Unit { Unit.allCases[unitPopUpButton.indexOfSelectedItem] }
    var name: String { nameTextField.stringValue }
    var save: Bool { saveCheckbox.state == .on }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lengthTextField.stringValue = "1"
        
        let unitNames = Unit.allCases.map(\.description)
        unitPopUpButton.addItems(withTitles: unitNames)
        
        saveCheckbox.state = .off
        
        updateUI()
    }
    
    private func updateUI() {
        let save = saveCheckbox.state == .on
        
        nameTextField.isEnabled = save
        
        if !save {
            nameTextField.stringValue = ""
        }
    }
    
    @IBAction func saveCheckboxAction(_ sender: NSButton) {
        updateUI()
        
        if sender.state == .on {
            nameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        guard let window = view.window else { return }
        window.sheetParent?.endSheet(window, returnCode: .cancel)
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        guard !save || !nameTextField.stringValue.isEmpty else {
            nameTextField.selectText(nil)
            nameTextField.becomeFirstResponder()
            NSSound.beep()
            return
        }
        guard Double(lengthTextField.stringValue) != nil else {
            lengthTextField.selectText(nil)
            lengthTextField.becomeFirstResponder()
            NSSound.beep()
            return
        }
        guard let window = view.window else { return }
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }
    
}
