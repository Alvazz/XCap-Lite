//
//  CameraListWindowController.swift
//  XCap
//
//  Created by scchn on 2021/4/21.
//

import Cocoa
import AVFoundation

import XCamera
import RxSwift
import RxCocoa

extension NSUserInterfaceItemIdentifier {
    static let main = NSUserInterfaceItemIdentifier("main")
}

extension NSToolbar.Identifier {
    static let main = NSToolbar.Identifier("main")
}

extension NSToolbarItem.Identifier {
    static let openImage = NSToolbarItem.Identifier("import")
    static let open = NSToolbarItem.Identifier("open")
}

class CameraListWindowController: BaseWindowController {
    
    private let disposeBag = DisposeBag()
    private var imageWindowControllers: [CameraWindowController] = []
    
    var windowModel: CameraListWindowModel!
    
    override func loadWindow() {
        let contentSize = UIConst.Main.contentSize
        let contentRect = CGRect(origin: .zero, size: contentSize)
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        window.setFrameAutosaveName("main")
        window.identifier = .main
        window.tabbingMode = .disallowed
        window.title = "XCap"
        
        window.setContentSize(contentSize)
        window.contentMinSize = contentSize
        window.contentMaxSize = contentSize
        
        let toolbar = NSToolbar(identifier: .main)
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        window.toolbar = toolbar
        
        self.window = window
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.center()
        
        checkCameraPermission()
        bindWindowModel()
    }
    
    private func requestPermission(_ completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            AVCaptureDevice.requestAccess(for: .video) { ok in
                DispatchQueue.main.async {
                    completionHandler(ok)
                }
            }
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .restricted:
            contentViewController = DeadViewController.instantiate(from: .main)
        case .denied:
            contentViewController = DenialViewController.instantiate(from: .main)
        default:
            let mainVC = CameraListViewController.instantiate(from: .main)
            let mainVM = windowModel.viewModel
            mainVC.viewModel = mainVM
            contentViewController = mainVC
            
            guard status == .notDetermined else { return mainVC.becomeSelectable() }
            requestPermission { ok in
                if ok {
                    mainVC.becomeSelectable()
                } else {
                    self.contentViewController = DenialViewController.instantiate(from: .main)
                }
            }
        }
    }
    
    private func bindWindowModel() {
        let input = CameraListWindowModel.Input()
        let output = windowModel.transform(input)
        
        disposeBag.insert([
            output.selectedItem.drive(onNext: { [weak self] item in
                guard let button = self?.window?.toolbar?.itemView(NSControl.self, identifier: .open) else { return }
                button.isEnabled = (item != nil)
            }),
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func imageOpenButtonAction(_ sender: Any) {
        NSApp.sendAction(#selector(AppDelegate.open(_:)), to: NSApp.delegate, from: nil)
    }
    
    @objc
    private func openButtonAction(_ sender: Any) {
        NSApp.sendAction(#selector(CameraListViewController.openCamera(_:)), to: contentViewController, from: nil)
    }
    
}

extension CameraListWindowController: NSToolbarDelegate {
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.openImage, .open]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.openImage, .open]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .open:
            let button = NSButton(image: #imageLiteral(resourceName: "play"), target: self, action: #selector(openButtonAction(_:)))
            button.bezelStyle = .texturedRounded
            let toolTip = "Toolbar.Open".localized()
            let item = NSToolbarItem(identifier: itemIdentifier, toolTip: toolTip, content: button)
            return item
        case .openImage:
            let button = NSButton(image: #imageLiteral(resourceName: "open_image"), target: self, action: #selector(imageOpenButtonAction(_:)))
            button.bezelStyle = .texturedRounded
            let toolTip = "Toolbar.Open_Image".localized()
            let item = NSToolbarItem(identifier: itemIdentifier, toolTip: toolTip, content: button)
            return item
        default:
            return nil
        }
    }
    
}
