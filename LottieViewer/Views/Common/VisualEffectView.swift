//
//  VisualEffectView.swift
//  AppleVideoOverlay
//
//  Created by Kacper Rączy on 27/07/2020.
//  Copyright © 2020 Kacper Rączy. All rights reserved.
//

import AppKit
import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    let state: NSVisualEffectView.State
    
    init(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode,
        state: NSVisualEffectView.State = .followsWindowActiveState
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = blendingMode
        view.material = material
        view.state = state
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
