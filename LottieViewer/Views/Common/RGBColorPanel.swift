//
//  RGBColorPanel.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 25/04/2022.
//

import SwiftUI
import AppKit
import Combine

class RGBColorPanel: ObservableObject {
    private static var _shared: RGBColorPanel?
    static var shared: RGBColorPanel {
        if _shared == nil {
            _shared = RGBColorPanel()
        }
        
        return _shared!
    }
    
    private let colorSubject = PassthroughSubject<NSColor, Never>()

    var colorPublisher: AnyPublisher<NSColor, Never> {
        colorSubject
            .throttle(for: 0.1, scheduler: RunLoop.main, latest: false)
            .eraseToAnyPublisher()
    }
    
    var colorPanel: NSColorPanel {
        return NSColorPanel.shared
    }
    
    var color: NSColor {
        get {
            colorPanel.color
        }
        set {
            if colorPanel.color == newValue {
                return
            }
            
            colorPanel.color = newValue
        }
    }
    
    init() {
        NSColorPanel.setPickerMask([.rgbModeMask, .grayModeMask, .wheelModeMask, .crayonModeMask])
        NSColorPanel.setPickerMode(.RGB)
        colorPanel.showsAlpha = true
        colorPanel.isContinuous = true
        colorPanel.setTarget(self)
        colorPanel.setAction(#selector(colorDidChange(sender:)))
    }
    
    deinit {
        colorPanel.setTarget(nil)
        colorPanel.setAction(nil)
    }
    
    func show() {
        colorPanel.makeKeyAndOrderFront(nil)
    }
    
    func hide() {
        colorPanel.close()
    }
    
    @objc func colorDidChange(sender: NSColorPanel) {
        guard let color = sender.color.usingColorSpace(.genericRGB) else {
            return
        }
        
        colorSubject.send(color)
    }
}
