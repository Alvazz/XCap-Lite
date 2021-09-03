//
//  CameraGeneralSettingsViewController.swift
//  XCap
//
//  Created by scchn on 2021/4/22.
//

import Cocoa

import XCanvas
import RxSwift
import RxCocoa
import RxBiBinding

class CameraGeneralSettingsViewController: NSViewController {
    
    // 影像
    @IBOutlet weak var formatRow: NSGridRow!
    @IBOutlet weak var formatPopUpButton: NSPopUpButton!
    @IBOutlet weak var horizontalFlipCheckbox: NSButton!
    @IBOutlet weak var verticalFlipCheckbox: NSButton!
    
    // 量測
    @IBOutlet weak var unitPopUpButton: NSPopUpButton!
    
    // 背景
    @IBOutlet weak var backgroundColorWell: NSColorWell!
    
    // 十字線
    @IBOutlet weak var crosshairCheckbox: NSButton!
    @IBOutlet weak var crosshairColorWell: NSColorWell!
    @IBOutlet weak var crosshairLineWidthPopUpButton: NSPopUpButton!
    
    private let disposeBag = DisposeBag()
    
    private var unit: ControlProperty<Unit> {
        let values = unitPopUpButton.rx.selection.compactMap(Unit.init(rawValue:))
        let sink = Binder<Unit>(unitPopUpButton) { button, unit in
            button.selectItem(at: unit.rawValue)
        }
        return .init(values: values, valueSink: sink)
    }
    
    private var crosshairLineWidth: ControlProperty<LineWidth> {
        let values = crosshairLineWidthPopUpButton.rx.selection.compactMap(LineWidth.init(rawValue:))
        let sinks = Binder<LineWidth>(crosshairLineWidthPopUpButton) { button, lineWidth in
            button.selectItem(at: lineWidth.rawValue)
        }
        return .init(values: values, valueSink: sinks)
    }
    
    var viewModel: CameraGeneralSettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let unitNames = Unit.allCases.map(\.description)
        unitPopUpButton.addItems(withTitles: unitNames)
        
        crosshairLineWidthPopUpButton.imagePosition = .imageOnly
        crosshairLineWidthPopUpButton.imageScaling = .scaleAxesIndependently
        for lineWidth in LineWidth.allCases {
            let title = String(Int(lineWidth.width))
            crosshairLineWidthPopUpButton.addItem(withTitle: title)
            crosshairLineWidthPopUpButton.lastItem?.image = lineWidth.image
        }
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = CameraGeneralSettingsViewModel.Input(
            flipHorizontal: horizontalFlipCheckbox.rx.toggle.asDriver(),
            flipVertical: verticalFlipCheckbox.rx.toggle.asDriver()
        )
        let output = viewModel.transform(input)
        
        disposeBag.insert([
            // 量測
            unit <-> viewModel.unit,
            // 背景
            backgroundColorWell.rx.color <-> viewModel.backgroundColor,
            // 十字線
            crosshairCheckbox.rx.on <-> viewModel.showsCrosshair,
            viewModel.showsCrosshair.bind(to: crosshairColorWell.rx.isEnabled),
            crosshairColorWell.rx.color <-> viewModel.crosshairColor,
            viewModel.showsCrosshair.bind(to: crosshairLineWidthPopUpButton.rx.isEnabled),
            crosshairLineWidth <-> viewModel.crosshairLineWidth,
        ])
        
        disposeBag.insert([
            output.flipHorizontal.drive(),
            output.flipVertical.drive(),
            output.isFlipHorizontal.drive(horizontalFlipCheckbox.rx.on),
            output.isFlipVertical.drive(verticalFlipCheckbox.rx.on),
        ])
        
        if let output = output.cameraRelated {
            disposeBag.insert([
                output.formats.bind(to: formatPopUpButton.rx.monospacedItems),
                formatPopUpButton.rx.selection <-> output.format,
                output.disconnected.drive(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.formatPopUpButton.menu?.cancelTracking()
                    self.unitPopUpButton.menu?.cancelTracking()
                    self.crosshairLineWidthPopUpButton.menu?.cancelTracking()
                }),
            ])
        } else {
            formatRow.isHidden = true
        }
    }
    
}
