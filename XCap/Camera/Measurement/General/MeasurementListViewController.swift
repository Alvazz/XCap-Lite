//
//  MeasurementListViewController.swift
//  XCap
//
//  Created by chen on 2021/5/11.
//

import Cocoa

import DifferenceKit
import RxSwift
import RxCocoa

extension NSUserInterfaceItemIdentifier {
    static let measurandColumn = NSUserInterfaceItemIdentifier("MeasurandColumn")
    static let valueColumn     = NSUserInterfaceItemIdentifier("ValueColumn")
    static let unitColumn      = NSUserInterfaceItemIdentifier("UnitColumn")
}

class MeasurementListViewController: NSViewController {
    
    @IBOutlet weak var outlineView: MeasurementOutlineView!
    @IBOutlet weak var generateTagButton: NSButton!
    
    var viewModel: MeasurementListViewModel!
    
    private let disposeBag = DisposeBag()
    private var results: [MeasurementResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.rowHeight = UIConst.Camera.Measurement.rowHeight
        outlineView.didDoubleClickRow = { row, item in
            guard let item = item as? MeasurementResult else { return }
            NotificationCenter.default.post(
                name: .didPerformMeasurementListAction,
                object: MeasurementListAction.selectObject(item.identifier)
            )
        }
        
        bindViewModel()
    }
    
    private func reload(_ newResults: [MeasurementResult]) {
        let newResults = newResults.filter { !$0.measurands.isEmpty }
        let changeset = StagedChangeset(source: results, target: newResults)
        
        outlineView.beginUpdates()
        defer {
            outlineView.endUpdates()
            results = newResults
        }
        
        for change in changeset {
            if !change.elementUpdated.isEmpty {
                let indexes = change.elementUpdated.toIndexSet()
                
                for index in indexes {
                    let item = results[index]
                    let result = newResults.first(where: {
                        $0.differenceIdentifier == item.differenceIdentifier
                    })
                    
                    if let result = result {
                        let isExpanded = outlineView.isItemExpanded(item)
                        let selectedRow = outlineView.selectedRow
                        
                        results[index] = result
                        outlineView.removeItems(at: [index], inParent: nil, withAnimation: [])
                        outlineView.insertItems(at: [index], inParent: nil, withAnimation: [])
                        
                        if isExpanded {
                            outlineView.expandItem(result)
                        }
                        
                        if selectedRow != -1 {
                            outlineView.selectRowIndexes([selectedRow], byExtendingSelection: false)
                        }
                    }
                }
            }
            
            if !change.elementDeleted.isEmpty {
                let indexes = change.elementDeleted.toIndexSet()
                outlineView.removeItems(at: indexes, inParent: nil, withAnimation: .effectFade)
            }

            if !change.elementInserted.isEmpty || !change.elementMoved.isEmpty {
                results = newResults
                
                for path in change.elementInserted {
                    let index = path.element
                    outlineView.insertItems(at: [index], inParent: nil, withAnimation: .effectFade)
                    outlineView.expandItem(results[index])
                }

                for (from, to) in change.elementMoved {
                    outlineView.moveItem(at: from.element, inParent: nil, to: to.element, inParent: nil)
                }
            }
        }
    }
    
    private func bindViewModel() {
        let hasResults = viewModel.results.map(\.isEmpty).not()
        
        disposeBag.insert([
            hasResults.bind(to: generateTagButton.rx.isEnabled),
            viewModel.results.subscribe(onNext: { [weak self] results in
                self?.reload(results)
            }),
        ])
    }
    
    // MARK: - Actions
    
    @IBAction func collapseButtonAction(_ sender: Any) {
        for result in results {
            outlineView.collapseItem(result)
        }
    }
    
    @IBAction func expandButtonAction(_ sender: Any) {
        for result in results {
            outlineView.expandItem(result)
        }
    }
    
    @IBAction func generateTagButtonAction(_ sender: Any) {
        let action = MeasurementListAction.generateTags(viewModel.sourceID)
        NotificationCenter.default.post(
            name: .didPerformMeasurementListAction,
            object: action
        )
    }
    
}

extension MeasurementListViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item else { return results.count }
        return (item as? MeasurementResult)?.measurands.count ?? 1
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item else { return results[index] }
        guard let result = item as? MeasurementResult else { return item }
        return result.measurands[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is MeasurementResult
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        UIConst.Camera.Measurement.rowHeight
    }
    
}

extension MeasurementListViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let columnID = tableColumn?.identifier else { return nil }
        
        switch item {
        case let result as MeasurementResult where columnID == .measurandColumn:
            let cellView = outlineView.makeView(MeasurandHeaderView.self)
            cellView.bind(to: result)
            return cellView
            
        case let result as MeasurementResult where columnID == .valueColumn:
            let cellView = outlineView.makeView(MeasurandValueHeaderView.self)
            cellView.bind(to: result)
            return cellView
            
        case let measurand as Measurand where columnID == .measurandColumn:
            let cellView = outlineView.makeView(MeasurandCellView.self)
            cellView.bind(to: measurand)
            return cellView
            
        case let measurand as Measurand where columnID == .valueColumn:
            let cellView = outlineView.makeView(MeasurandValueCellView.self)
            cellView.bind(to: measurand)
            return cellView
            
        case let measurand as Measurand where columnID == .unitColumn:
            let cellView = outlineView.makeView(MeasurandUnitCellView.self)
            cellView.bind(to: measurand)
            return cellView
            
        default:
            return nil
        }
    }
    
}

class MeasurementOutlineView: NSOutlineView {
    
    var didDoubleClickRow: ((Int, Any) -> Void)?
    var menuHandler: ((NSEvent) -> NSMenu?)?
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        guard event.clickCount == 2 else { return }
        let point = convert(event.locationInWindow, from: nil)
        let row = row(at: point)
        if row != -1, let item = item(atRow: row) {
            didDoubleClickRow?(row, item)
        }
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        menuHandler?(event)
    }
    
}

fileprivate extension Array where Element == ElementPath {
    
    func toIndexSet() -> IndexSet {
        IndexSet(self.map(\.element))
    }
    
}
