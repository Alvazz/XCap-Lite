//
//  MeasurementWindowController.swift
//  XCap
//
//  Created by chen on 2021/6/20.
//

import Cocoa

import RxSwift
import RxCocoa

enum MeasurementTab: String, CustomStringConvertible, CaseIterable {
    
    case general
    
    var description: String {
        switch self {
        case .general: return "MeasurementTab.general".localized(table: .Models)
        }
    }
    
    var image: NSImage {
        switch self {
        case .general: return #imageLiteral(resourceName: "measurement_tab_measurements")
        }
    }
    
}

extension NSUserInterfaceItemIdentifier {
    static let measurements = NSUserInterfaceItemIdentifier("measurements")
}

class MeasurementWindowController: BaseWindowController {
    
    private let disposeBag = DisposeBag()
    private let contentSize = UIConst.Camera.Measurement.contentSize
    
    var windowModel: MeasurementWindowModel!
    
    var willClose: (() -> Void)?
    
    override func loadWindow() {
        let contentRect = CGRect(origin: .zero, size: contentSize)
        let styleMask: NSWindow.StyleMask = [
            .titled, .closable, .miniaturizable, .resizable
        ]
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        
        window.setFrameAutosaveName("measurements")
        window.identifier = .measurements
        window.tabbingMode = .disallowed
        window.title = "Measurements.Title".localized()
        window.delegate = self
        
        self.window = window
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let contentViewController = MeasurementViewController.instantiate(from: .main)
        contentViewController.viewModel = windowModel.viewModel
        self.contentViewController = contentViewController
        
        window?.contentMinSize = contentSize
        window?.setContentSize(contentSize)
    }
    
    // MARK: - Actions
    
    @objc
    private func tabSegmentedControlAction(_ sender: NSSegmentedControl) {
        guard let viewController = contentViewController as? MeasurementViewController else { return }
        viewController.selectTab(at: sender.indexOfSelectedItem)
    }
    
}

extension MeasurementWindowController: NSWindowDelegate {
    
    func windowDidBecomeKey(_ notification: Notification) {
        window?.level = .floating
    }
    
    func windowDidResignKey(_ notification: Notification) {
        window?.level = .normal
    }
    
    func windowWillClose(_ notification: Notification) {
        willClose?()
    }
    
}
