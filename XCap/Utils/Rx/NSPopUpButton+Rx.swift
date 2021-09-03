//
//  NSPopUpButton+Rx.swift
//  XCap
//
//  Created by scchn on 2021/4/22.
//

import Cocoa

import RxSwift
import RxCocoa

fileprivate extension NSMenuItem {
    
    static func monoItem(withTitle title: String) -> NSMenuItem {
        let size = NSFont.systemFontSize
        let font = NSFont(name: "Menlo", size: size) ?? .systemFont(ofSize: size)
        let item = NSMenuItem()
        item.attributedTitle = NSAttributedString(
            string: title,
            attributes: [.font: font]
        )
        return item
    }
    
}

extension Reactive where Base == NSPopUpButton {
    
    var items: Binder<[String]> {
        Binder<[String]>(base) {
            $0.removeAllItems()
            $0.addItems(withTitles: $1)
        }
    }
    
    var monospacedItems: Binder<[String]> {
        Binder(base) { control, titles in
            control.menu?.items = titles.map(NSMenuItem.monoItem(withTitle:))
        }
    }
    
    var selection: ControlProperty<Int> {
        controlProperty(
            getter: { $0.indexOfSelectedItem },
            setter: { $0.selectItem(at: $1) }
        )
    }
    
    var select: ControlEvent<Int> {
        let select = controlEvent.map { base.indexOfSelectedItem }
        return .init(events: select)
    }
    
}
