//
//  CameraWindowController.swift
//  XCap
//
//  Created by scchn on 2021/4/21.
//

import Cocoa

import RxSwift
import RxCocoa
import RxBiBinding

extension NSUserInterfaceItemIdentifier {
    static let camera = NSUserInterfaceItemIdentifier("camera")
}

extension NSToolbar.Identifier {
    static let camera = NSToolbar.Identifier("camera")
}

extension NSToolbarItem.Identifier {
    static let displayMode = NSToolbarItem.Identifier("displayMode")
    static let capture     = NSToolbarItem.Identifier("capture")
    static let newWindow   = NSToolbarItem.Identifier("newWindow")
    static let record      = NSToolbarItem.Identifier("record")
    static let settings    = NSToolbarItem.Identifier("settings")
}

extension Notification.Name {
    static let didCreateWindowWithSnapshot = Notification.Name("com.scchn.XCap.didCreateWindowWithSnapshot")
}

class CameraWindowController: BaseWindowController {
    
    lazy
    private var measurementWindowController: MeasurementWindowController = {
        let windowController = MeasurementWindowController()
        windowController.windowModel = windowModel.measurementWindowModel
        windowController.willClose = { [weak self] in
            guard let self = self,
                  let viewController = self.contentViewController as? CameraViewController
            else { return }
            
            self.windowModel.automaticallyHideTags.accept(true)
        }
        return windowController
    }()
    
    private let disposeBag = DisposeBag()
    private var displayMode: ControlProperty<DisplayMode> {
        guard let button = window?.toolbar?.itemView(NSPopUpButton.self, identifier: .displayMode) else {
            fatalError()
        }
        let values = button.rx.selection.compactMap(DisplayMode.init(rawValue:))
        let sink = Binder<DisplayMode>(button) { button, mode in
            button.selectItem(at: mode.rawValue)
        }
        return .init(values: values, valueSink: sink)
    }
    
    private let contentSize = UIConst.Camera.contentSize
    
    var windowModel: CameraWindowModel!
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
        
        window.setFrameAutosaveName("camera")
        window.identifier = .camera
        window.tabbingMode = .disallowed
        window.delegate = self
        
        let toolbar = NSToolbar(identifier: .camera)
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        window.toolbar = toolbar
        
        self.window = window
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let contentViewController = CameraViewController.instantiate(from: .main)
        contentViewController.viewModel = windowModel.viewModel
        self.contentViewController = contentViewController
        
        window?.contentMinSize = contentSize
        window?.setContentSize(contentSize)
        window?.center()
        window?.title = windowModel.title
        
        bindWindowModel()
    }
    
    private func recordingStateDidChange(_ isRecording: Bool) {
        guard let item = window?.toolbar?.itemView(NSButton.self, identifier: .record) else { return }
        item.image = isRecording ? #imageLiteral(resourceName: "recording_on") : #imageLiteral(resourceName: "recording_off")
        item.isEnabled = true
    }
    
    private func saveVideo(from fileURL: URL) {
        guard let window = window else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["mov"]
        savePanel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = savePanel.url else {
                try? FileManager.default.removeItem(at: fileURL)
                return
            }
            do {
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                }
                
                try fileManager.moveItem(at: fileURL, to: url)
            } catch {
                DispatchQueue.main.async {
                    let title = "Common.Error.Write_File_Failed_Format".localized(error.localizedDescription)
                    NSAlert(title: title, style: .critical)
                        .beginSheetModal(for: window)
                }
            }
        }
    }
    
    private func cameraDidDisconnect() {
        guard let window = window else { return }
        
        if let sheet = window.attachedSheet {
            window.endSheet(sheet)
        }
        
        let title = "Camera.Disconnected".localized()
        NSAlert(title: title, style: .critical)
            .beginSheetModal(for: window) { response in
                self.close()
            }
    }
    
    private func bindWindowModel() {
        let input = CameraWindowModel.Input()
        let output = windowModel.transform(input)
        
        disposeBag.insert([
            displayMode <-> windowModel.displayMode,
        ])
        
        if let output = output.cameraRelated {
            disposeBag.insert([
                output.isRecording.drive(onNext: { [weak self] isRecording in
                    self?.recordingStateDidChange(isRecording)
                }),
                output.recordingBegan.drive(),
                output.recordingFinished.drive(onNext: { [weak self] fileURL in
                    self?.saveVideo(from: fileURL)
                }),
                output.disconnected.drive(onNext: { [weak self] in
                    self?.cameraDidDisconnect()
                }),
            ])
        }
    }
    
    // MARK: - Actions
    
    @IBAction
    private func captureAndOpen(_ sender: Any) {
        windowModel.createCameraWinowModelWithSnapshot { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(windowModel):
                let windowController = CameraWindowController()
                windowController.windowModel = windowModel
                NotificationCenter.default.post(
                    name: .didCreateWindowWithSnapshot,
                    object: windowController
                )
            case let .failure(error):
                if let window = self.window {
                    let title = error.localizedDescription
                    NSAlert(title: title, style: .critical)
                        .beginSheetModal(for: window)
                }
            }
        }
    }
    
    @objc
    private func captureButtonAction(_ sender: Any) {
        NSApp.sendAction(#selector(CameraViewController.saveDocument(_:)), to: contentViewController, from: nil)
    }
    
    @objc
    private func recordButtonAction(_ sender: NSButton) {
        guard let window = window else { return }
        guard windowModel.toggleRecording() else {
            return NSAlert(title: "Camera.Error.Recording_Failed".localized())
                .beginSheetModal(for: window)
        }
        sender.isEnabled = false
    }
    
    @objc
    private func settingsButtonAction(_ sender: Any) {
        NSApp.sendAction(#selector(CameraViewController.showPreferences(_:)), to: contentViewController, from: nil)
    }
    
    @IBAction
    func showMeasurements(_ sender: Any?) {
        windowModel.automaticallyHideTags.accept(false)
        measurementWindowController.showWindow(nil)
    }
    
}

extension CameraWindowController: NSWindowDelegate {
    
    func windowDidBecomeKey(_ notification: Notification) {
        measurementWindowController.window?.level = .floating
    }
    
    func windowDidResignKey(_ notification: Notification) {
        measurementWindowController.window?.level = .normal
    }
    
    func windowWillClose(_ notification: Notification) {
        measurementWindowController.close()
        
        willClose?()
    }
    
}

extension CameraWindowController: NSToolbarDelegate {
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.displayMode, .capture, .newWindow, .record, .settings, .flexibleSpace]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        windowModel.isCameraSource ?
            [.displayMode, .flexibleSpace, .newWindow, .capture, .record, .settings] :
            [.displayMode, .flexibleSpace, .newWindow, .capture, .settings]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .displayMode:
            let button = NSPopUpButton()
            let titles = DisplayMode.allCases.map(\.description)
            button.addItems(withTitles: titles)
            let item = NSToolbarItem(identifier: itemIdentifier, content: button)
            return item
        case .newWindow:
            let button = NSButton(image: #imageLiteral(resourceName: "capture_and_open"), target: self, action: #selector(captureAndOpen(_:)))
            button.bezelStyle = .texturedRounded
            let toolTip = "Toolbar.New_Window_With_Snapshot".localized()
            let item = NSToolbarItem(identifier: itemIdentifier, toolTip: toolTip, content: button)
            return item
        case .capture:
            let button = NSButton(image: #imageLiteral(resourceName: "capture"), target: self, action: #selector(captureButtonAction(_:)))
            button.bezelStyle = .texturedRounded
            let toolTip = "Toolbar.Capture".localized()
            let item = NSToolbarItem(identifier: itemIdentifier, toolTip: toolTip, content: button)
            return item
        case .record:
            let button = NSButton(image: #imageLiteral(resourceName: "recording_on"), target: self, action: #selector(recordButtonAction(_:)))
            button.bezelStyle = .texturedRounded
            let toolTip = "Toolbar.Record".localized()
            let item = NSToolbarItem(identifier: itemIdentifier, toolTip: toolTip, content: button)
            return item
        case .settings:
            let button = NSButton(image: #imageLiteral(resourceName: "settings"), target: self, action: #selector(settingsButtonAction(_:)))
            button.bezelStyle = .texturedRounded
            let toolTip = "Toolbar.Preferences".localized()
            let item = NSToolbarItem(identifier: itemIdentifier, toolTip: toolTip, content: button)
            return item
        default:
            return nil
        }
    }
    
}
