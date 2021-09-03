//
//  ScaleListViewController.swift
//  XCap
//
//  Created by scchn on 2021/5/31.
//

import Cocoa

import DifferenceKit
import RxSwift

extension NSUserInterfaceItemIdentifier {
    static let scaleName = NSUserInterfaceItemIdentifier("scaleName")
    static let scaleValue = NSUserInterfaceItemIdentifier("scaleValue")
}

class ScaleListViewController: NSViewController {
    
    @IBOutlet weak var scaleTableView: TableView!
    @IBOutlet weak var okButton: NSButton!
    
    var viewModel: ScaleListViewModel!
    
    private let disposeBag = DisposeBag()
    private var listItems: [ScaleListViewModel.ListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scaleTableView.dataSource = self
        scaleTableView.delegate = self
        scaleTableView.rowHeight = UIConst.Camera.ScaleList.rowHeight
        scaleTableView.didDoubleClickRow = { [weak self] row in
            self?.viewModel.setScale(at: row)
            self?.dismiss(nil)
        }
        scaleTableView.menuHandler = { [weak self] event, row in
            self?.menu(for: row)
        }
        
        okButton.isEnabled = false
        
        bindViewModel()
    }
    
    private func reload(with target: [ScaleListViewModel.ListItem]) {
        let changeset = StagedChangeset(source: listItems, target: target)
        scaleTableView.reload(using: changeset, with: .effectFade) { [weak self] items in
            self?.listItems = items
        }
    }
    
    private func menu(for row: Int?) -> NSMenu? {
        guard let row = row else { return nil }
        scaleTableView.selectRowIndexes([row], byExtendingSelection: false)
        let menu = NSMenu()
        menu.addItem(localizedTitle: "Common.Delete", action: #selector(self.deleteListItem(_:)))
        return menu
    }
    
    private func bindViewModel() {
        disposeBag.insert([
            viewModel.listItems.subscribe(onNext: { [weak self] scales in
                self?.reload(with: scales)
            }),
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func deleteListItem(_ sender: Any) {
        guard let index = scaleTableView.altSelectedRow else { return }
        viewModel.deleteScale(at: index)
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        guard let index = scaleTableView.altSelectedRow else { return }
        viewModel.setScale(at: index)
        dismiss(nil)
    }
    
}

extension ScaleListViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        listItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columID = tableColumn?.identifier else { return nil }
        
        let item = listItems[row]
        
        switch columID {
        case .scaleName:
            let cellView = tableView.makeView(ScaleNameCellView.self)
            cellView.bind(to: item)
            cellView.textField?.stringValue = item.name
            cellView.imageView?.image = NSImage(named: item.isSelected ? NSImage.statusAvailableName : NSImage.statusNoneName)
            cellView.editHandler = { [weak self, weak cellView] name in
                guard let self = self, let view = cellView else { return }
                let row = self.scaleTableView.row(for: view)
                if row != -1 {
                    self.viewModel.renameScale(name: name, at: row)
                }
            }
            return cellView
        case .scaleValue:
            let cellView = tableView.makeView(NSTableCellView.self, identifier: columID)
            cellView.textField?.stringValue = item.detail
            return cellView
        default:
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        okButton.isEnabled = scaleTableView.altSelectedRow != nil
    }
    
}
