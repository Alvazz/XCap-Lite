//
//  AppCoordinator.swift
//  XCap
//
//  Created by scchn on 2021/4/21.
//

import Cocoa

extension Storyboard {
    static let main     = Storyboard("Main")
    static let panel    = Storyboard("Panel")
    static let support  = Storyboard("Support")
}

class AppCoordinator {
    
    private var aboutWindowController: AboutWindowController?
    private var helpWindowController: HelpWindowController?
    
    let windowController: CameraListWindowController
    
    init() {
        windowController = CameraListWindowController()
        windowController.windowModel = CameraListWindowModel()
        
        let center = NotificationCenter.default
        
        center.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: .main) { noti in
            guard let window = noti.object as? NSWindow else { return }
            if window == self.aboutWindowController?.window {
                self.aboutWindowController = nil
            } else if window == self.helpWindowController?.window {
                self.helpWindowController = nil
            }
        }
    }
    
    func start() {
        NSColorPanel.shared.showsAlpha = true
        windowController.showWindow(nil)
    }
    
    func reopen() {
        windowController.showWindow(nil)
    }
    
    func openFile() {
        guard let viewControler = windowController.contentViewController as? CameraListViewController else { return }
        
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = NSImage.imageTypes
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK, let fileURL = openPanel.url {
            viewControler.openFile(at: fileURL)
        }
    }
    
    func showAbout() {
        if aboutWindowController == nil {
            let windowController = AboutWindowController.instantiate(from: .support)
            aboutWindowController = windowController
        }
        aboutWindowController?.showWindow(nil)
    }
    
    func showHelp() {
        if helpWindowController == nil {
            let windowController = HelpWindowController.instantiate(from: .support)
            helpWindowController = windowController
        }
        helpWindowController?.showWindow(nil)
    }
    
}
