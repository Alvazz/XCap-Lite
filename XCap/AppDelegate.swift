//
//  AppDelegate.swift
//  XCap
//
//  Created by chen on 2021/4/21.
//

import Cocoa
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let appCoordinator = AppCoordinator()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        appCoordinator.start()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            appCoordinator.reopen()
        }
        return true
    }

    // MARK: - App Menu
    
    @IBAction func showAbout(_ sender: Any?) {
        appCoordinator.showAbout()
    }
    
    // MARK: - File Menu
    
    @IBAction func open(_ sender: Any?) {
        appCoordinator.openFile()
    }
    
    // MARK: - Window Menu
    
    @IBAction func openDeviceListWindow(_ sender: Any) {
        appCoordinator.reopen()
    }

    // MARK: - Help Menu
    
    @IBAction func showHelp(_ sender: Any?) {
        appCoordinator.showHelp()
    }
    
}
