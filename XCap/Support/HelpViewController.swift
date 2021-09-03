//
//  HelpViewController.swift
//  XCap
//
//  Created by chen on 2021/7/3.
//

import Cocoa

enum HelpCategory: CaseIterable, CustomStringConvertible {
    case calibration
    case rotation
    case tags
    
    var description: String {
        switch self {
        case .calibration:  return "HelpCategory.Calibration".localized(table: .Models)
        case .rotation:     return "HelpCategory.Rotation".localized(table: .Models)
        case .tags:         return "HelpCategory.Tags".localized(table: .Models)
        }
    }
    
    var detail: String {
        switch self {
        case .calibration:  return "HelpCategory.Calibration.Detail".localized(table: .Models)
        case .rotation:     return "HelpCategory.Rotation.Detail".localized(table: .Models)
        case .tags:         return "HelpCategory.Tags.Detail".localized(table: .Models)
        }
    }
    
    var image: NSImage {
        switch self {
        case .calibration: return #imageLiteral(resourceName: "help_calibration")
        case .rotation: return #imageLiteral(resourceName: "help_rotation")
        case .tags: return #imageLiteral(resourceName: "help_tags")
        }
    }
    
}

class HelpViewController: NSViewController {
    
    @IBOutlet weak var categoryPopUpButton: NSPopUpButton!
    @IBOutlet weak var detailLabel: NSTextField!
    @IBOutlet weak var imageView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let categoryNames = HelpCategory.allCases.map(\.description)
        categoryPopUpButton.removeAllItems()
        categoryPopUpButton.addItems(withTitles: categoryNames)
        
        imageView.layer = CALayer()
        imageView.wantsLayer = true
        imageView.layer?.contentsGravity = .resizeAspect
        
        selectCategory(at: 0)
    }
    
    private func selectCategory(at index: Int) {
        let category = HelpCategory.allCases[index]
        categoryPopUpButton.selectItem(at: index)
        detailLabel.stringValue = category.detail
        imageView.layer?.contents = category.image
    }
    
    @IBAction func categoryPopUpButtonAction(_ sender: NSPopUpButton) {
        selectCategory(at: sender.indexOfSelectedItem)
    }
    
}
