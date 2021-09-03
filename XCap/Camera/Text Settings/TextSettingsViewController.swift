//
//  TextSettingsViewController.swift
//  XCap
//
//  Created by chen on 2021/6/3.
//

import Cocoa

class TextSettingsViewController: NSViewController, ControlPropertyAdaptable {
    
    @IBOutlet weak var colorWell: NSColorWell!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var stepper: NSStepper!
    
    private let sizeRange: ClosedRange<Double> = 2...200
    
    @objc dynamic
    var color: NSColor = .black {
        didSet { updateUI() }
    }
    
    @objc dynamic
    var size: CGFloat = 13 {
        didSet { updateUI() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.minValue = sizeRange.lowerBound
        stepper.maxValue = sizeRange.upperBound
        updateUI()
    }
    
    private func updateUI() {
        guard isViewLoaded else { return }
        colorWell.color = color
        textField.stringValue = size.description
        stepper.doubleValue = Double(size)
    }
    
    @IBAction func colorWellAction(_ sender: NSColorWell) {
        color = sender.color
    }
    
    @IBAction func textFieldAction(_ sender: NSTextField) {
        guard let doubleValue = Double(sender.stringValue), sizeRange.contains(doubleValue)
        else { return updateUI() }
        size = CGFloat(doubleValue)
    }
    
    @IBAction func stepperAction(_ sender: NSStepper) {
        size = CGFloat(sender.doubleValue)
    }
    
}
