//
//  MeasurementViewController.swift
//  XCap
//
//  Created by chen on 2021/6/20.
//

import Cocoa

enum MeasurementListAction {
    case selectObject(Int)
    case changeObjectTag(Int, String)
    case generateTags(UUID)
}

extension Notification.Name {
    static let didPerformMeasurementListAction = Notification.Name("com.scchn.XCap.didPerformMeasurementListAction")
}

class MeasurementViewController: NSViewController {
    
    @IBOutlet weak var tabView: NSTabView!
    
    var viewModel: MeasurementViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab View
        tabView.tabViewItems.forEach(tabView.removeTabViewItem)
        tabView.tabViewType = .noTabsNoBorder
        
        for tab in MeasurementTab.allCases {
            guard let viewController = makeViewController(with: tab) else { continue }
            let item = NSTabViewItem(viewController: viewController)
            tabView.addTabViewItem(item)
        }
        
        tabView.selectTabViewItem(at: 0)
    }
    
    private func makeViewController(with tab: MeasurementTab) -> NSViewController? {
        switch tab {
        case .general:
            let viewController = MeasurementListViewController.instantiate(from: .main)
            viewController.viewModel = viewModel.measurementListViewModel
            return viewController
        }
        
    }
    
    override func cancelOperation(_ sender: Any?) {
        view.window?.close()
    }
    
    func selectTab(at index: Int) {
        tabView.selectTabViewItem(at: index)
    }
    
}
