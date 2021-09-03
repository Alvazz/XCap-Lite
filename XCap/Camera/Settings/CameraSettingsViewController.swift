//
//  CameraSettingsViewController.swift
//  XCap
//
//  Created by scchn on 2021/4/28.
//

import Cocoa
import Carbon.HIToolbox

enum SettingsTab: String, CustomStringConvertible, CaseIterable {
    
    case general
    
    var description: String {
        switch self {
        case .general: return "SettingsTab.general".localized(table: .Models)
        }
    }
    
    var image: NSImage {
        switch self {
        case .general: return #imageLiteral(resourceName: "general_settings")
        }
    }
    
}

class CameraSettingsViewController: NSViewController {
    
    private typealias TabInfo = (tab: SettingsTab, viewController: NSViewController)
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var tabControl: TabControl!
    
    var viewModel: CameraSettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = view as? KeyCaptureView {
            view.keyEquivalentHandler = { [weak self] keyCode, modifierFlags in
                guard let self = self, keyCode == kVK_Escape else { return false }
                self.dismiss(nil)
                return true
            }
        }
        
        let tabInfoArray: [TabInfo] = SettingsTab.allCases
            .compactMap { tab in
                guard let viewController = makeViewController(with: tab) else { return nil }
                return (tab, viewController)
            }
        
        tabView.tabViewType = .noTabsNoBorder
        tabView.tabViewItems.forEach(tabView.removeTabViewItem)
        tabControl.tabCount = tabInfoArray.count
        
        for (i, (tab, viewController)) in tabInfoArray.enumerated() {
            // Tab Control
            tabControl.setLabel(tab.description, forTabAt: i)
            tabControl.setImage(tab.image, forTabAt: i)
            // Tab View
            let tabViewItem = NSTabViewItem(viewController: viewController)
            tabViewItem.label = tab.description
            tabViewItem.image = tab.image
            tabView.addTabViewItem(tabViewItem)
        }
        
        if !tabInfoArray.isEmpty {
            tabControl.selectTab(at: 0)
            tabView.selectTabViewItem(at: 0)
        }
        
        if tabInfoArray.count < 2 {
            tabControl.isHidden = true
        }
    }
    
    private func makeViewController(with tab: SettingsTab) -> NSViewController? {
        switch tab {
        case .general:
            let viewController = CameraGeneralSettingsViewController.instantiate(from: .main)
            viewController.viewModel = viewModel.generalViewModel
            return viewController
        }
    }
    
    @IBAction func tabControlAction(_ sender: TabControl) {
        tabView.selectTabViewItem(at: sender.indexOfSelectedTab)
    }
    
}
