//
//  CanvasView+Rx.swift
//  XCap
//
//  Created by scchn on 2021/5/7.
//

import Cocoa

import XCanvas
import RxSwift
import RxCocoa

extension CanvasView: ControlPropertyAdaptable {}

extension Reactive where Base == CanvasView {
    
    var strokeColor: ControlProperty<NSColor> {
        base.rx.controlProperty(\.strokeColor) { canvasView, color in
            canvasView.currentObject?.strokeColor = color
            canvasView.selectedObjects.forEach { object in
                object.strokeColor = color
            }
        }
    }
    
    var fillColor: ControlProperty<NSColor> {
        base.rx.controlProperty(\.fillColor) { canvasView, color in
            canvasView.currentObject?.fillColor = color
            canvasView.selectedObjects.forEach { object in
                object.fillColor = color
            }
        }
    }
    
    var lineWidth: ControlProperty<LineWidth> {
        var emmit = true
        let values = Observable<LineWidth>.create { observer in
            let observation = self.base.observe(\.lineWidth, options: [.initial, .new]) { canvasView, _ in
                guard emmit, let lineWidth = LineWidth(width: canvasView.lineWidth) else { return }
                observer.onNext(lineWidth)
            }
            return Disposables.create(with: observation.invalidate)
        }
        let sink = Binder<LineWidth>(base) { canvasView, lineWidth in
            emmit = false
            let width = lineWidth.width
            canvasView.lineWidth = width
            canvasView.currentObject?.lineWidth = width
            canvasView.selectedObjects.forEach { object in
                object.lineWidth = width
            }
            emmit = true
        }
        
        return ControlProperty<LineWidth>(values: values, valueSink: sink)
    }
    
    var textColor: Binder<NSColor> {
        Binder<NSColor>(base) { canvasView, textColor in
            var textboxes = canvasView.selectedObjects.compactMap { $0 as? TextboxObject }
            if let textbox = canvasView.currentObject as? TextboxObject {
                textboxes += [textbox]
            }
            for textbox in textboxes {
                textbox.textColor = textColor
            }
        }
    }
    
    var textSize: Binder<CGFloat> {
        Binder<CGFloat>(base) { canvasView, textSize in
            let font = NSFont.systemFont(ofSize: textSize)
            var textboxes = canvasView.selectedObjects.compactMap { $0 as? TextboxObject }
            if let textbox = canvasView.currentObject as? TextboxObject {
                textboxes += [textbox]
            }
            for textbox in textboxes {
                textbox.font = font
            }
        }
    }
    
}
