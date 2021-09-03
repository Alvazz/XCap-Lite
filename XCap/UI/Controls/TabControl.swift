//
//  TabControl.swift
//  XCap
//
//  Created by scchn on 2021/7/28.
//

import Cocoa

fileprivate extension NSBox {
    
    private static func separator() -> NSBox {
        let separator = NSBox()
        separator.boxType = .custom
        separator.title = ""
        separator.borderWidth = 0
        separator.cornerRadius = 0
        separator.fillColor = .separatorColor
        return separator
    }
    
    static func verticalSeparator() -> NSBox {
        let separator = NSBox.separator()
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    static func horizontalSeparator() -> NSBox {
        let separator = NSBox.separator()
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
}

fileprivate class TabItem {
    
    var label: String
    var image: NSImage
    var isSelected: Bool = false
    
    init(label: String, image: NSImage) {
        self.label = label
        self.image = image
    }
    
}

class TabControl: NSControl {
    
    private let containerStackView = NSStackView()
    
    private var tabItems: [TabItem] = []
    
    var tabCount: Int = 0 {
        didSet {
            update()
        }
    }
    
    @objc dynamic private(set)
    var indexOfSelectedTab: Int = -1
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.orientation = .horizontal
        containerStackView.distribution = .fillEqually
        containerStackView.spacing = 0
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    private func updateTabItems() {
        let diff = tabCount - tabItems.count
        
        guard diff != 0 else { return }
        
        if diff > 0 {
            for _ in 0..<diff {
                let image = NSImage(named: NSImage.actionTemplateName)!
                let item = TabItem(label: "Tab", image: image)
                tabItems.append(item)
            }
        } else {
            for _ in 0..<abs(diff) {
                tabItems.removeLast()
            }
        }
        
        if !(0..<tabItems.count).contains(indexOfSelectedTab) {
            indexOfSelectedTab = -1
        }
    }
    
    private func update() {
        updateTabItems()
        
        containerStackView.arrangedSubviews
            .forEach(containerStackView.removeView(_:))
        
        for (index, item) in tabItems.enumerated() {
            let button = PlainButton(title: item.label, image: item.image)
            button.target = self
            button.action = #selector(tabButtonAction(_:))
            button.imageHugsTitle = true
            button.imageInset = CGVector(dx: 6, dy: 6)
            button.tag = index
            
            if !item.isSelected {
                button.drawsBackground = true
                button.backgroundColor = .controlHighlightColor
            }
            
            let separator = NSBox.horizontalSeparator()
            separator.alphaValue = item.isSelected ? 0 : 1
            
            let stackView = NSStackView(views: [button, separator])
            stackView.orientation = .vertical
            stackView.distribution = .fill
            stackView.spacing = 0
            
            containerStackView.addArrangedSubview(stackView)
            stackView.heightAnchor.constraint(equalTo: containerStackView.heightAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            
            if index < tabItems.count - 1 {
                let separator = NSBox.verticalSeparator()
                containerStackView.addArrangedSubview(separator)
            }
        }
    }
    
    @objc
    private func tabButtonAction(_ sender: PlainButton) {
        guard indexOfSelectedTab != sender.tag else { return }
        selectTab(at: sender.tag)
        sendAction(action, to: target)
    }
    
    func setLabel(_ label: String, forTabAt index: Int) {
        tabItems[index].label = label
        update()
    }
    
    func setImage(_ image: NSImage, forTabAt index: Int) {
        tabItems[index].image = image
        update()
    }
    
    func selectTab(at index: Int) {
        for (aIndex, item) in tabItems.enumerated() {
            item.isSelected = aIndex == index
        }
        indexOfSelectedTab = index
        update()
    }
    
}
