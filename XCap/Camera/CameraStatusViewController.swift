//
//  CameraStatusViewController.swift
//  XCap
//
//  Created by scchn on 2021/5/11.
//

import Cocoa

import RxSwift
import RxCocoa
import RxBiBinding

class CameraStatusViewController: NSViewController {
    
    // 比例尺
    @IBOutlet weak var scaleButton: NSButton!
    @IBOutlet weak var scaleAddButton: NSButton!
    
    // 倍率
    @IBOutlet weak var magnificationLabel: NSTextField!
    
    // 錄影
    @IBOutlet weak var recordStackView: NSStackView!
    @IBOutlet weak var recordImageView: NSImageView!
    @IBOutlet weak var recordLabel: NSTextField!
    
    private let disposeBag = DisposeBag()
    
    var viewModel: CameraStatusViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        bindViewModel()
    }
    
    private func showScaleInfo(_ info: CameraStatusViewModel.ScaleInfo?) {
        guard let window = view.window else { return }
        
        let title = info?.detail ?? "Scale.No_Calibration".localized()
        let style: NSAlert.Style = info != nil ? .informational : .critical
        
        NSAlert(title: title, style: style)
            .beginSheetModal(for: window)
    }
    
    private func showAddScaleAlert(name: String?) {
        guard let window = view.window else { return }
        let alert = NSAlert.textFieldAlert(
            title: "Scale.Save_Current_Scale.Title".localized(),
            placeholder: "Scale.Save_Current_Scale.Placeholder".localized(),
            default: name ?? ""
        )
        
        alert.beginTextFieldSheetModal(for: window) { response, text in
            guard response == .alertFirstButtonReturn else { return }
            
            let name = text.trimmingCharacters(in: .whitespaces)
            
            guard !name.isEmpty else {
                return DispatchQueue.main.async {
                    let title = "Scale.Empty_Name".localized()
                    NSAlert(title: title)
                        .beginSheetModal(for: window)
                }
            }
            self.viewModel.addCurrentScale(with: name)
        }
    }
    
    private func updateRecordingUI(state: (text: String, light: Bool)?) {
        guard let state = state else {
            recordStackView.isHidden = true
            return
        }
        recordStackView.isHidden = false
        recordImageView.alphaValue = state.light ? 1 : 0
        recordLabel.stringValue = state.text
    }
    
    private func bindViewModel() {
        guard let window = view.window else {
            fatalError("The view of `\(self)` is not currently installed in any window.")
        }
        
        let input = CameraStatusViewModel.Input(
            screen: window.rx.screen.asDriverOnErrorJustComplete()
        )
        let output = viewModel.transform(input)
        
        disposeBag.insert([
            viewModel.scaleInfo.subscribe(onNext: { [weak self] info in
                guard let self = self else { return }
                let title = info?.title ?? "-"
                self.scaleButton.title = title
                self.scaleAddButton.isEnabled = info?.isSaved == false
            }),
        ])
        
        disposeBag.insert([
            output.magnification.drive(magnificationLabel.rx.text),
            scaleButton.rx.tap.withLatestFrom(viewModel.scaleInfo) { [weak self] _, info in
                guard let self = self else { return }
                self.showScaleInfo(info)
            }
            .subscribe(),
            scaleAddButton.rx.tap.withLatestFrom(viewModel.scale) { [weak self] _, scale in
                guard let self = self else { return }
                self.showAddScaleAlert(name: scale?.name)
            }
            .subscribe(),
        ])
        
        if let output = output.cameraRelated {
            disposeBag.insert([
                output.recordingBegan.drive(),
                output.recordingFinished.drive(),
                output.recordingInfo.drive(onNext: { [weak self] state in
                    self?.updateRecordingUI(state: state)
                }),
            ])
        } else {
            recordStackView.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func measurementButtonAction(_ sender: Any) {
        guard let windowController = view.window?.windowController as? CameraWindowController else { return }
        windowController.showMeasurements(nil)
    }
    
    @IBAction func scaleListButtonAction(_ sender: NSButton) {
        let viewController = ScaleListViewController.instantiate(from: .panel)
        viewController.viewModel = viewModel.createScaleListViewModel()
        present(
            viewController,
            asPopoverRelativeTo: sender.bounds, of: sender,
            preferredEdge: .minY, behavior: .transient
        )
    }
    
}
