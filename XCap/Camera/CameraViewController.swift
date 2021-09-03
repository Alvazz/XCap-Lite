//
//  CameraViewController.swift
//  XCap
//
//  Created by scchn on 2021/4/21.
//

import Cocoa
import Carbon.HIToolbox

import XCanvas
import RxSwift
import RxCocoa
import RxBiBinding

fileprivate typealias Pasteboard = CanvasObjectPasteboard<MeasurementTool>

fileprivate let baseOffset: CGFloat = 30

class CameraViewController: NSViewController {
    
    // 量測工具列
    @IBOutlet weak var measurementToolStackView: NSStackView!
    
    // 上方工具列
    @IBOutlet weak var strokeColorWell: NSColorWell!
    @IBOutlet weak var fillColorWell: NSColorWell!
    @IBOutlet weak var lineWidthPopUpButton: NSPopUpButton!
    @IBOutlet weak var textSettingsButton: NSButton!
    
    // 預覽畫面
    @IBOutlet weak var previewContainerView: NSView!
    @IBOutlet weak var previewScrollView: NSScrollView!
    @IBOutlet weak var previewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewView: NSView!
    @IBOutlet weak var crosshairView: CrosshairView!
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var tagView: TagView!
    
    // 文字設定
    private let textSettingsViewController = TextSettingsViewController.instantiate(from: .panel)
    
    // 偏好設定
    private let settingsAnimator = SidebarAnimator(position: .right, width: UIConst.Camera.settingsWidth)
    private let settingsViewController = CameraSettingsViewController.instantiate(from: .main)
    private var isSettingsVisible: Bool { settingsViewController.presentingViewController != nil }
    
    private let disposeBag = DisposeBag()
    private let rxPreviewBounds = BehaviorRelay<CGRect>(value: .zero)
    private let rxUpdateSelection = PublishRelay<Void>()
    private let rxCurrentTool = BehaviorRelay<MeasurementTool?>(value: nil)
    // 包含移動、編輯、旋轉、修改標籤
    private let rxModifyObject = PublishRelay<Void>()
    private let rxIsPerformingSaliencyAnalyzing = BehaviorRelay<Bool>(value: false)
    
    private var lineWidth: ControlProperty<LineWidth> {
        let values = lineWidthPopUpButton.rx.selection.compactMap(LineWidth.init(rawValue:))
        let sink = Binder<LineWidth>(lineWidthPopUpButton) { button, lineWidth in
            button.selectItem(at: lineWidth.rawValue)
        }
        return ControlProperty(values: values, valueSink: sink)
    }
    
    private var updateTags: Observable<Void> {
        PublishRelay.of(rxUpdateSelection, rxModifyObject).merge().startWith(())
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.canvasView.rx.value(\.objects).mapToVoid()
            }
    }
    
    private var measurements: Observable<[Measurable]> {
        rxModifyObject.startWith(())
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] _ -> Observable<[Measurable]> in
                guard let self = self else { return .empty() }
                return self.canvasView.rx.value(\.objects)
                    .map { $0.compactMap { $0 as? Measurable } }
                    .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            }
    }
    
    private var notificationObservers: [NSObjectProtocol] = []
    private var pasteOffset: CGPoint = .zero
    
    var viewModel: CameraViewModel!
    
    deinit {
        notificationObservers.forEach(NotificationCenter.default.removeObserver(_:))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsViewController.viewModel = viewModel.settingsViewModel
        
        rxPreviewBounds.accept(previewScrollView.bounds)
        
        setupKeyCaptureView()
        setupMeasurementToolbar()
        setupTopToolbar()
        setupPreviewArea()
        bindViewModel()
        setupObservers()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        switch segue.destinationController {
        case let vc as CameraStatusViewController:
            vc.viewModel = viewModel.statusViewModel
        default:
            break
        }
    }
    
    private func setupKeyCaptureView() {
        guard let view = view as? KeyCaptureView else { return }
        
        view.flagsChangeHandler = { [weak self] flags in
            guard let self = self else { return }
            
            self.canvasView.isObjectRotatable = flags == [.option]
            
            if self.viewModel.automaticallyHideTags.value {
                self.tagView.isHidden = flags != [.control, .command]
            }
        }
    }
    
    private func setupMeasurementToolbar() {
        func createButton(image: NSImage, toolTip: String, tag: Int) -> PlainButton {
            let button = PlainButton(image: image)
            
            button.target = self
            button.action = #selector(measurementToolButtonAction(_:))
            button.backgroundColor = .tertiaryLabelColor
            button.imageInset = CGVector(dx: 6, dy: 6)
            button.toolTip = toolTip
            button.tag = tag
            
            button.widthAnchor.constraint(equalToConstant: 32).isActive = true
            button.heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            return button
        }
        
        let cursorButton = createButton(image: #imageLiteral(resourceName: "cursor"), toolTip: "Canvas.Selection_Tool".localized(), tag: -1)
        
        measurementToolStackView.arrangedSubviews.forEach(measurementToolStackView.removeView(_:))
        measurementToolStackView.addArrangedSubview(cursorButton)
        
        for measurementTool in MeasurementTool.allCases {
            let button = createButton(
                image: measurementTool.image,
                toolTip: measurementTool.toolTip,
                tag: measurementTool.index
            )
            measurementToolStackView.addArrangedSubview(button)
        }
    }
    
    private func setupTopToolbar() {
        lineWidthPopUpButton.imagePosition = .imageOnly
        lineWidthPopUpButton.imageScaling = .scaleAxesIndependently
        for lineWidth in LineWidth.allCases {
            lineWidthPopUpButton.addItem(withTitle: String(Int(lineWidth.width)))
            lineWidthPopUpButton.lastItem?.image = lineWidth.image
        }
    }
    
    private func setupPreviewArea() {
        let previewLayer = viewModel.previewLayer
        previewLayer.frame = previewView.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        previewView.wantsLayer = true
        previewView.layer?.addSublayer(previewLayer)
        
        canvasView.delegate = self
        canvasView.backgroundColor = .clear
        canvasView.foregroundColor = .clear
        canvasView.isObjectRotatable = false
        
        tagView.isHidden = true
    }
    
    private func setupObservers() {
        let center = NotificationCenter.default
        
        notificationObservers += [
            center.addObserver(forName: NSView.frameDidChangeNotification, object: previewScrollView, queue: .main) { [weak self] notification in
                guard let self = self else { return }
                self.rxPreviewBounds.accept(self.previewScrollView.bounds)
            },
            center.addObserver(forName: CanvasObject.tagDidChangeNotification, object: nil, queue: .main) { [weak self] notification in
                guard let self = self,
                      let object = notification.object as? CanvasObject,
                      self.canvasView.objects.contains(object)
                else { return }
                self.rxModifyObject.accept(())
            },
            center.addObserver(forName: .didPerformMeasurementListAction, object: nil, queue: .main) { [weak self] notification in
                guard let self = self else { return }
                self.didReceiveMeasurementListAction(notification)
            },
        ]
    }
    
    private func didReceiveMeasurementListAction(_ notification: Notification) {
        guard let action = notification.object as? MeasurementListAction else { return }
        
        switch action {
        case let .selectObject(hash):
            if let object = canvasView.objects.first(where: { $0.hash == hash }) {
                canvasView.selectObjects([object])
            }
        
        case let .changeObjectTag(hash, tag):
            if let object = canvasView.objects.first(where: { $0.hash == hash }) {
                object.updateTag(tag)
                canvasView.selectObjects([object])
            }
            
        case let .generateTags(uuid):
            guard uuid == viewModel.sourceID else { break }
            canvasView.generateTags()
        }
    }
    
    // MARK: - Binding
    
    private func updateMeasurementTool(_ tool: MeasurementTool?) {
        let toolButtons = measurementToolStackView.arrangedSubviews.compactMap { $0 as? PlainButton }
        let selectionIdex = (tool?.index ?? -1) + 1
        
        for (i, button) in toolButtons.enumerated() {
            button.drawsBackground = selectionIdex == i
        }
    }
    
    private func bindViewModel() {
        let input = CameraViewModel.Input(
            previewBounds: rxPreviewBounds.asDriver(),
            updateMeasurements: measurements.asDriverOnErrorJustComplete()
        )
        let output = viewModel.transform(input)
        
        disposeBag.insert([
            output.previewSize.drive(onNext: { [weak self] size in
                guard let self = self else { return }
                self.previewWidthConstraint.constant = size.width
                self.previewHeightConstraint.constant = size.height
            }),
            output.updateMeasurements.drive(),
            output.disconnect.drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.lineWidthPopUpButton.menu?.cancelTracking()
                if self.isSettingsVisible {
                    self.showPreferences(nil)
                }
            }),
        ])
        
        // 背景
        disposeBag.insert([
            viewModel.backgroundColor.bind(to: previewScrollView.rx.backgroundColor),
        ])
        
        // 十字線
        disposeBag.insert([
            viewModel.dimensions.bind(to: crosshairView.rx.contentSize),
            viewModel.showsCrosshair.not().bind(to: crosshairView.rx.isHidden),
            viewModel.crosshairColor.bind(to: crosshairView.rx.color),
            viewModel.crosshairLineWidth.bind(to: crosshairView.rx.lineWidth),
        ])
        
        // 畫布
        disposeBag.insert([
            viewModel.dimensions.subscribe(onNext: { [weak self] dimensions in
                self?.canvasView.updateCanvasSize(dimensions)
                self?.rxModifyObject.accept(())
            }),
            // Stroke Color
            canvasView.rx.strokeColor <-> viewModel.strokeColor,
            strokeColorWell.rx.color <-> viewModel.strokeColor,
            // Fill Color
            canvasView.rx.fillColor <-> viewModel.fillColor,
            fillColorWell.rx.color <-> viewModel.fillColor,
            // Line Width
            canvasView.rx.lineWidth <-> viewModel.lineWidth,
            lineWidth <-> viewModel.lineWidth,
            // Text Color
            textSettingsViewController.rx.controlProperty(\.color) <-> viewModel.textColor,
            viewModel.textColor.bind(to: canvasView.rx.textColor),
            // Text Size
            textSettingsViewController.rx.controlProperty(\.size) <-> viewModel.textSize,
            viewModel.textSize.bind(to: canvasView.rx.textSize),
        ])
        
        // 標籤
        disposeBag.insert([
            viewModel.dimensions.bind(to: tagView.rx.contentSize),
            viewModel.automaticallyHideTags.bind(to: tagView.rx.isHidden),
            updateTags.subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let others = self.canvasView.objects
                    .filter { !self.canvasView.selectedObjects.contains($0) }
                let selection = self.canvasView.selectedObjects
                self.tagView.update(with: others + selection)
            })
        ])
        
        // 其他
        let resignKeyWindow = NotificationCenter.default.rx.notification(NSWindow.didResignKeyNotification)
            .filter { [weak self] in $0.object as? NSWindow == self?.view.window }
            .mapToVoid()
        
        disposeBag.insert([
            resignKeyWindow.subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.canvasView.isObjectRotatable = false
                
                if self.viewModel.automaticallyHideTags.value {
                    self.tagView.isHidden = true
                }
            }),
            rxCurrentTool.subscribe(onNext: { [weak self] tool in
                self?.updateMeasurementTool(tool)
            }),
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func measurementToolButtonAction(_ sender: PlainButton) {
        guard sender.tag != -1 else {
            cancelOperation(nil)
            return
        }
        
        let tool = MeasurementTool.allCases[sender.tag]
        let object = canvasView.startDrawingSession(ofType: tool.objectType)
        
        if let textbox = object as? TextboxObject {
            let font = NSFont.systemFont(ofSize: textSettingsViewController.size)
            textbox.textColor = textSettingsViewController.color
            textbox.font = font
        }
    }
    
    @IBAction func textSettingsButtonAction(_ sender: NSButton) {
        present(
            textSettingsViewController,
            asPopoverRelativeTo: sender.bounds, of: sender,
            preferredEdge: .maxY, behavior: .transient
        )
    }
    
    @objc
    private func resetRotation(_ sender: Any?) {
        guard let object = canvasView.selectedObject else { return }
        canvasView.registerUndoRotation(object, rotation: object.rotation)
        object.rotate(.degrees(0))
    }
    
    @objc
    private func editTag(_ sender: Any?) {
        guard let object = canvasView.selectedObject,
              let window = view.window
        else { return }
        
        let alert = NSAlert.textFieldAlert(title: "Canvas.Object.Edit_Tag".localized(), default: object.tag)
        let button = alert.addButton(withTitle: "Canvas.Object.Remove_Tag".localized())
        
        button.isEnabled = object.tag != ""
        
        alert.beginTextFieldSheetModal(for: window) { response, text in
            switch response {
            case .alertFirstButtonReturn: object.updateTag(text)
            case .alertThirdButtonReturn: object.updateTag("")
            default: break
            }
        }
    }
    
    @objc
    private func editText(_ sender: Any?) {
        guard let window = view.window,
              let object = canvasView.selectedObject as? TextboxObject
        else { return }
        
        let textEditor = TextEditor(text: object.text)
        
        textEditor.beginSheetModel(for: window) { response in
            guard response == .OK, textEditor.text != object.text else { return }
            object.text = textEditor.text
        }
    }
    
    @objc
    private func toggleTextboxBackground(_ sender: Any?) {
        guard let object = canvasView.selectedObject as? TextboxObject else { return }
        object.drawsBackground.toggle()
    }
    
    @IBAction
    private func calibrate(_ sender: Any?) {
        guard let window = view.window,
              let object = canvasView.selectedObject as? Calibratable
        else { return }
        
        let canvasWidth = canvasView.canvasSize.width
        let calibrationValue = object.calibrationValue
        let panel = ScaleSavePanel()
        
        panel.beginSheetModel(for: window) { response in
            guard response == .OK else { return }
            let unitLength = calibrationValue / panel.length
            let fov = canvasWidth / unitLength
            let save = panel.save
            let name = save ? panel.name : nil
            let scale = Scale(fov: fov, unit: panel.unit, name: name)
            self.viewModel.calibrate(with: scale, save: save)
        }
    }
    
    @objc
    private func addCenterLine(_ sender: Any?) {
        guard canvasView.selectedObjects.count == 2,
              let circle1 = (canvasView.selectedObjects.first as? Circular),
              let circle2 = (canvasView.selectedObjects.last as? Circular)
        else { return }
        
        let from = circle1.center
        let to = circle2.center
        let lineObject = LineObject()
        lineObject.push(point: from)
        lineObject.push(point: to)
        lineObject.strokeColor = canvasView.strokeColor
        lineObject.lineWidth = canvasView.lineWidth
        canvasView.addObjects([lineObject])
    }
    
    // MARK: - App Actions
    
    @IBAction
    func showPreferences(_ sender: Any?) {
        guard !settingsAnimator.isAnimating else { return }
        
        if isSettingsVisible {
            settingsViewController.dismiss(nil)
        } else {
            present(settingsViewController, animator: settingsAnimator)
        }
    }
    
    override func cancelOperation(_ sender: Any?) {
        canvasView.stopDrawingSession()
        canvasView.deselectAllObjects()
    }
    
    // MARK: - File Actions
    
    private func createSnapshot(with image: NSImage) -> NSImage {
        if viewModel.snapshotWithGraphics.value {
            image.lockFocus()
            
            if !crosshairView.isHidden {
                crosshairView.drawSnapshot(contentSize: image.size)
            }
            
            canvasView.drawSnapshotShot(size: image.size, objectsOnly: true)
            
            if viewModel.snapshotWithTags.value {
                tagView.drawSnapshot(contentSize: image.size)
            }
            
            image.unlockFocus()
        }
        
        return image
    }
    
    private func showCreateSnapshotError() {
        guard let window = view.window else { return }
        
        DispatchQueue.main.async {
            let title = "Camera.Error.Create_Snapshot_Failed".localized()
            
            NSAlert(title: title, style: .critical)
                .beginSheetModal(for: window)
        }
    }
    
    private func showWriteFileError(_ error: Error) {
        guard let window = view.window else { return }
        
        DispatchQueue.main.async {
            let title = "Common.Error.Write_File_Failed_Format".localized(error.localizedDescription)
            NSAlert(title: title, style: .critical)
                .beginSheetModal(for: window)
        }
    }
    
    private func saveSnapshot(with image: NSImage) {
        guard let window = view.window else { return }
        
        let savePanel = NSSavePanel()
        let accessoryViewController = SavePanelAccessoryViewController.instantiate(from: .panel)
        accessoryViewController.saveFormat = viewModel.snapshotFileFormat.value
        accessoryViewController.saveGraphics = viewModel.snapshotWithGraphics.value
        accessoryViewController.saveTags = viewModel.snapshotWithTags.value
        accessoryViewController.savePanel = savePanel
        savePanel.accessoryView = accessoryViewController.view
        savePanel.beginSheetModal(for: window) { response in
            self.viewModel.snapshotFileFormat.accept(accessoryViewController.saveFormat)
            self.viewModel.snapshotWithGraphics.accept(accessoryViewController.saveGraphics)
            self.viewModel.snapshotWithTags.accept(accessoryViewController.saveTags)
            
            guard response == .OK, let fileURL = savePanel.url else { return }
            
            let snapshot = self.createSnapshot(with: image)
            let fileType = self.viewModel.snapshotFileFormat.value.fileType
            
            guard let data = snapshot.representation(using: fileType) else {
                return self.showCreateSnapshotError()
            }
            
            do {
                try data.write(to: fileURL)
            } catch {
                self.showWriteFileError(error)
            }
        }
    }
    
    @objc
    func saveDocument(_ sender: Any?) {
        viewModel.capture { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(image):
                self.saveSnapshot(with: image)
                
            case let .failure(error):
                if let window = self.view.window {
                    NSAlert(title: error.localizedDescription, style: .critical)
                        .beginSheetModal(for: window)
                }
            }
        }
    }
    
    // MARK: - Edit Actions
    
    @objc
    func cut(_ sender: Any?) {
        let pasteboard = Pasteboard(objects: canvasView.selectedObjects)
        
        if pasteboard.write(to: .general) {
            canvasView.removeSelectedObjects()
            pasteOffset = .zero
        }
    }
    
    @objc
    func copy(_ sender: Any?) {
        let pasteboard = Pasteboard(objects: canvasView.selectedObjects)
        
        if pasteboard.write(to: .general) {
            pasteOffset = CGPoint(x: baseOffset, y: baseOffset)
        }
    }

    @objc
    func paste(_ sender: Any?) {
        guard let pasteboard = Pasteboard.getInstance(from: .general) else { return }
        
        let objects = pasteboard.objects
        
        for object in objects {
            object.translate(x: pasteOffset.x, y: pasteOffset.y)
        }
        
        canvasView.addObjects(objects)
        canvasView.selectObjects(objects)
        
        let transform = CGAffineTransform(translationX: baseOffset, y: baseOffset)
        pasteOffset = pasteOffset.applying(transform)
    }
    
    @objc
    func delete(_ sender: Any?) {
        canvasView.discardCurrentObject()
        canvasView.removeSelectedObjects()
    }
    
    override func selectAll(_ sender: Any?) {
        canvasView.stopDrawingSession()
        canvasView.selectAllObjects() 
    }
    
}

extension CameraViewController: NSMenuItemValidation {
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(delete(_:)):
            return !canvasView.selectedObjects.isEmpty || canvasView.currentObject != nil
        case #selector(copy(_:)), #selector(cut(_:)):
            return !canvasView.selectedObjects.isEmpty
        case #selector(paste(_:)):
            return Pasteboard.canRead(from: .general)
        case #selector(resetRotation(_:)):
            return (canvasView.selectedObject?.rotation ?? 0) != 0
        case #selector(editTag(_:)):
            return canvasView.selectedObject != nil
        case #selector(calibrate(_:)):
            return canvasView.selectedObject is Calibratable
        default:
            return true
        }
    }
    
}

extension CameraViewController: CanvasViewDelegate {
    
    func canvasView(_ canvasView: CanvasView, didStartSession object: CanvasObject) {
        let measurementTool = MeasurementTool(type(of: object))
        rxCurrentTool.accept(measurementTool)
    }
    
    func canvasView(_ canvasView: CanvasView, didFinishSession object: CanvasObject) {
        rxCurrentTool.accept(nil)
    }
    
    func canvasViewDidCancelSession(_ canvasView: CanvasView) {
        rxCurrentTool.accept(nil)
    }
    
    func canvasView(_ canvasView: CanvasView, didMove objects: [CanvasObject]) {
        rxModifyObject.accept(())
    }
    
    func canvasView(_ canvasView: CanvasView, didEdit object: CanvasObject, at indexPath: IndexPath) {
        rxModifyObject.accept(())
    }
    
    func canvasView(_ canvasView: CanvasView, didRotate object: CanvasObject) {
        rxModifyObject.accept(())
    }
    
    func canvasView(_ canvasView: CanvasView, didSelect objects: Set<CanvasObject>) {
        rxUpdateSelection.accept(())
    }
    
    func canvasView(_ canvasView: CanvasView, didDeselect objects: Set<CanvasObject>) {
        rxUpdateSelection.accept(())
    }
    
    func canvasView(_ canvasView: CanvasView, didDoubleClick object: CanvasObject) {
        if canvasView.selectedObject is TextboxObject {
            editText(nil)
        }
    }
    
    func canvasView(_ canvasView: CanvasView, menuForObject object: CanvasObject?) -> NSMenu? {
        let menu = NSMenu()
        
        menu.addItem(localizedTitle: "Common.Cut", action: #selector(cut(_:)))
        menu.addItem(localizedTitle: "Common.Copy", action: #selector(copy(_:)))
        menu.addItem(localizedTitle: "Common.Paste", action: #selector(paste(_:)))
        menu.addItem(localizedTitle: "Common.Delete", action: #selector(delete(_:)))
        menu.addItem(.separator())
        menu.addItem(localizedTitle: "Canvas.Menu.Reset_Rotation", action: #selector(resetRotation(_:)))
        menu.addItem(localizedTitle: "Canvas.Menu.Edit_Tag", action: #selector(editTag(_:)))
        
        let selectedObject = canvasView.selectedObject
        let selectedObjects = canvasView.selectedObjects
        
        if let textbox = selectedObject as? TextboxObject {
            menu.addItem(.separator())
            menu.addItem(localizedTitle: "Canvas.Menu.Edit_Text", action: #selector(editText(_:)))
            menu.addItem(localizedTitle: "Canvas.Menu.Background", action: #selector(toggleTextboxBackground(_:)))
                .state = textbox.drawsBackground ? .on : .off
        }
        
        if selectedObject is Calibratable {
            menu.addItem(.separator())
            menu.addItem(localizedTitle: "Canvas.Menu.Calibrate", action: #selector(calibrate(_:)))
        }
        
        if selectedObjects.count == 2 && selectedObjects is [Circular]  {
            menu.addItem(.separator())
            menu.addItem(localizedTitle: "Canvas.Menu.Add_Line", action: #selector(addCenterLine(_:)))
        }
        
        menu.items.forEach { $0.target = self }
        
        return menu
    }
    
}
