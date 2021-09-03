//
//  SavePanelAccessoryViewController.swift
//  XCap
//
//  Created by scchn on 2021/6/22.
//

import Cocoa

enum ImageFileFormat: Int, CaseIterable, CustomStringConvertible {
    
    case png
    case jpeg
    case tiff
    
    var fileType: NSBitmapImageRep.FileType {
        switch self {
        case .png:  return .png
        case .jpeg: return .jpeg
        case .tiff: return .tiff
        }
    }
    
    var description: String {
        switch self {
        case .png:  return "PNG"
        case .jpeg: return "JPEG"
        case .tiff: return "TIFF"
        }
    }
    
    var fileTypes: [String] {
        switch self {
        case .png:  return ["png"]
        case .jpeg: return ["jpeg", "jpg"]
        case .tiff: return ["tiff"]
        }
    }
    
}

struct ImageSavePanelConfig {
    var fileType: NSBitmapImageRep.FileType
    var snapshotWithGraphics: Bool
}

class SavePanelAccessoryViewController: NSViewController {
    
    @IBOutlet weak var formatPopUpButton: NSPopUpButton!
    @IBOutlet weak var graphicsCheckbox: NSButton!
    @IBOutlet weak var tagCheckbox: NSButton!
    
    weak var savePanel: NSSavePanel?
    
    var saveFormat: ImageFileFormat = .png
    var saveGraphics: Bool = true
    var saveTags: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(savePanel != nil)
        
        let formatNames = ImageFileFormat.allCases.map(\.description)
        formatPopUpButton.removeAllItems()
        formatPopUpButton.addItems(withTitles: formatNames)
        
        formatPopUpButton.selectItem(at: saveFormat.rawValue)
        graphicsCheckbox.state = saveGraphics ? .on : .off
        tagCheckbox.state = saveTags ? . on : .off
        
        tagCheckbox.isEnabled = saveGraphics
        savePanel?.allowedFileTypes = saveFormat.fileTypes
    }
    
    @IBAction func formatPopUpButtonAction(_ sender: NSPopUpButton) {
        guard let format = ImageFileFormat(rawValue: sender.indexOfSelectedItem) else { return }
        saveFormat = format
        savePanel?.allowedFileTypes = saveFormat.fileTypes
    }
    
    @IBAction func graphicsCheckboxAction(_ sender: NSButton) {
        saveGraphics = sender.state == .on
        tagCheckbox.isEnabled = saveGraphics
    }
    
    @IBAction func tagCheckboxAction(_ sender: NSButton) {
        saveTags = sender.state == .on
    }
    
}
