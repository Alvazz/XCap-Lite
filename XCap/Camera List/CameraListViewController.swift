//
//  CameraListViewController.swift
//  XCap
//
//  Created by chen on 2021/4/21.
//

import Cocoa
import AVFoundation

import XCamera
import DifferenceKit
import RxSwift
import RxCocoa

extension NSUserInterfaceItemIdentifier {
    static let name         = NSUserInterfaceItemIdentifier("Name")
    static let manufacturer = NSUserInterfaceItemIdentifier("Manufacturer")
}

class CameraListViewController: NSViewController {
    
    @IBOutlet weak var cameraTableView: TableView!
    
    private var blockView = SolidView(color: .blockColor)
    
    private let disposeBag = DisposeBag()
    private let rxSelection = BehaviorRelay<Int?>(value: nil)
    private let rxOpen = PublishRelay<Int>()
    
    private var imageWindowControllers: [CameraWindowController] = []
    private var cameraWindowControllers: [CameraListItem: CameraWindowController] = [:]
    
    private var activeItems: [CameraListItem] { Array(cameraWindowControllers.keys) }
    private var listItems: [CameraListItem] = []
    
    private(set)
    var isItemSelectable: Bool = false
    
    var viewModel: CameraListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = UIConst.Main.contentSize
        
        cameraTableView.dataSource = self
        cameraTableView.delegate = self
        cameraTableView.rowHeight = UIConst.Main.rowHeight
        cameraTableView.didDoubleClickRow = { [weak self] _ in
            self?.openCamera(nil)
        }
        
        setupObservers()
        addBlockView()
        bindViewModel()
    }
    
    private func setupObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(forName: .didCreateWindowWithSnapshot, object: nil, queue: .main) { [weak self] notification in
            guard let self = self, let windowController = notification.object as? CameraWindowController else { return }
            self.addImageWindowController(windowController)
        }
    }
    
    private func addBlockView() {
        view.addSubview(blockView)
        blockView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blockView.topAnchor.constraint(equalTo: view.topAnchor),
            blockView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blockView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blockView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func reloadList(items: [CameraListItem]) {
        let changeset = StagedChangeset(source: listItems, target: items)
        cameraTableView.reload(using: changeset, with: .effectFade) { [weak self] data in
            self?.listItems = data
        }
    }
    
    private func reloadRow(with item: CameraListItem) {
        guard let index = listItems.firstIndex(of: item) else { return }
        let rows = IndexSet([index])
        let cols = IndexSet(0..<cameraTableView.numberOfColumns)
        cameraTableView.reloadData(forRowIndexes: rows, columnIndexes: cols)
    }
    
    private func bindViewModel() {
        let input = CameraListViewModel.Input(
            selection: rxSelection.asDriverOnErrorJustComplete()
        )
        let output = viewModel.transform(input)
        
        disposeBag.insert([
            output.items.drive(onNext: { [weak self] items in
                self?.reloadList(items: items)
            }),
            output.selection.drive(),
        ])
    }
    
    private func addImageWindowController(_ windowController: CameraWindowController) {
        windowController.willClose = { [weak self, weak windowController] in
            guard let self = self, let windowController = windowController,
                  let index = self.imageWindowControllers.firstIndex(of: windowController)
            else { return }
            self.imageWindowControllers.remove(at: index)
        }
        windowController.showWindow(nil)
        imageWindowControllers.append(windowController)
    }
    
    func openFile(at fileURL: URL) {
        guard let windowModel = viewModel.createCameraWindowModel(fileURL: fileURL) else {
            let title = "Image.Error.Open_Image_Failed".localized()
            NSAlert(title: title, style: .critical).runModal()
            return
        }
        
        let windowController = CameraWindowController()
        windowController.windowModel = windowModel
        addImageWindowController(windowController)
    }
    
    func becomeSelectable() {
        isItemSelectable = true
        blockView.removeFromSuperview()
    }
    
    // MARK: - Actions
    
    @objc
    func openCamera(_ sender: Any?) {
        guard let index = cameraTableView.altSelectedRow,
              listItems.indices.contains(index)
        else { return }
        
        let item = listItems[index]
        
        if let windowController = cameraWindowControllers[item] {
            windowController.showWindow(nil)
        } else if let windowModel = viewModel.createCameraWindowModel(cameraListItem: item) {
            let windowController = CameraWindowController()
            windowController.windowModel = windowModel
            windowController.willClose = { [weak self] in
                self?.cameraWindowControllers.removeValue(forKey: item)
                self?.reloadRow(with: item)
            }
            windowController.showWindow(nil)
            cameraWindowControllers[item] = windowController
            reloadRow(with: item)
        } else if let window = view.window {
            let title = "Camera.Invalid_Device.Title".localized()
            let message = "Camera.Invalid_Device.Message".localized()
            let alert = NSAlert(title: title, message: message, style: .critical)
            alert.addButton(withTitle: "Common.OK".localized())
            alert.beginSheetModal(for: window)
        }
    }
    
}

extension CameraListViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        listItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier else { return nil }

        let cellView = tableView.makeView(NSTableCellView.self, identifier: id)
        let item = listItems[row]
        var image: NSImage?
        var content: String
        
        switch id {
        case .name:
            let isActive = activeItems.contains(item)
            image = NSImage(named: isActive ? NSImage.statusAvailableName : NSImage.statusNoneName)
            content = item.name
        case .manufacturer:
            content = item.manufacturer
        default:
            fatalError("Unknown cell ID")
        }
        
        content = content.trimmingCharacters(in: .whitespaces)
        content = content.ifEmpty("<N/A>")
        
        cellView.imageView?.image = image
        cellView.textField?.stringValue = content
        cellView.toolTip = content

        return cellView
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        isItemSelectable
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        rxSelection.accept(cameraTableView.altSelectedRow)
    }
    
}
