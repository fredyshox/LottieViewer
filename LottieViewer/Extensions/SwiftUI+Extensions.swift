//
//  SwiftUI+Extensions.swift
//  AppleVideoOverlay
//
//  Created by Kacper Rączy on 27/07/2020.
//  Copyright © 2020 Kacper Rączy. All rights reserved.
//

import SwiftUI
import AppKit

extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

extension Color {
    public init(hex6: UInt32, alpha: CGFloat = 1) {
        let nsColor = NSColor(hex6: hex6, alpha: alpha)
        self.init(nsColor)
    }
}
