//
//  SidebarAnimator.swift
//
//
//  Created by scchn on 2021/4/22.
//

import Cocoa
import Carbon.HIToolbox

public enum SidebarPosition {
    case left
    case right
}

public class SidebarAnimator: NSObject, NSViewControllerPresentationAnimator {
    
    private let backgroundView: SolidView
    private let position: SidebarPosition
    private let sidebarWidth: CGFloat
    
    public var isAnimating = false
    public var backgroundColor: NSColor {
        get { backgroundView.color }
        set { backgroundView.color = newValue }
    }
    
    public init(position: SidebarPosition, width: CGFloat, background: NSColor = .clear) {
        self.backgroundView = SolidView(color: background)
        self.position = position
        self.sidebarWidth = width
    }
    
    public func animatePresentation(of toViewController: NSViewController, from fromViewController: NSViewController) {
        isAnimating = true
        
        let fromView = fromViewController.view
        let toView = toViewController.view
        let x = (position == .left) ? 0 : fromView.bounds.width - sidebarWidth
        let finalFrame =  CGRect(x: x, y: 0, width: sidebarWidth, height: fromView.bounds.height)
        var initFrame = finalFrame
        initFrame.origin.x += (position == .left) ? -sidebarWidth : sidebarWidth
        
        backgroundView.clickHandler = { [weak toViewController] point, _ in
            guard let view = toViewController?.view, view.hitTest(point) == nil else { return }
            toViewController?.dismiss(nil)
        }
        backgroundView.autoresizingMask = [.width, .height]
        backgroundView.frame = fromView.bounds
        backgroundView.alphaValue = 0
        fromView.addSubview(backgroundView)
        
        toView.frame = initFrame
        toView.autoresizingMask = (position == .left) ? .height : [.minXMargin, .height]
        fromView.addSubview(toView)
        
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup { ctx in
                self.backgroundView.animator().alphaValue = 1
                toViewController.view.animator().frame = finalFrame
            } completionHandler: {
                self.isAnimating = false
            }
        }
    }
    
    public func animateDismissal(of toViewController: NSViewController, from fromViewController: NSViewController) {
        isAnimating = true
        
        NSAnimationContext.runAnimationGroup { ctx in
            backgroundView.animator().alphaValue = 0
            toViewController.view.animator().frame.origin.x += (position == .left) ? -sidebarWidth : sidebarWidth
        } completionHandler: {
            toViewController.view.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            self.isAnimating = false
        }
    }
    
}
