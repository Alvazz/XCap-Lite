//
//  BaseViewController.swift
//  
//
//  Created by scchn on 2021/4/15.
//

import Cocoa

open class BaseViewController: NSViewController {
    
    private var box: NSBox?
    
    open var backgroundColor: NSColor? {
        didSet {
            addBackgroundBoxIfNeeded()
            box?.fillColor = backgroundColor ?? .clear
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func loadView() {
        view = NSView()
    }
    
    private func addBackgroundBoxIfNeeded() {
        guard box == nil else { return }
        
        let bgBox = NSBox()
        bgBox.translatesAutoresizingMaskIntoConstraints = false
        bgBox.boxType = .custom
        bgBox.borderWidth = 0
        bgBox.cornerRadius = 0
        bgBox.fillColor = .clear
        
        view.addSubview(bgBox)
        NSLayoutConstraint.activate([
            bgBox.topAnchor.constraint(equalTo: view.topAnchor),
            bgBox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgBox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgBox.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        box = bgBox
    }
    
}
