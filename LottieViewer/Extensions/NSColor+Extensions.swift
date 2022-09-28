//
//  NSColor+Extensions.swift
//  AppleVideoOverlay
//
//  Created by Kacper Rączy on 27/07/2020.
//  Copyright © 2020 Kacper Rączy. All rights reserved.
//

import AppKit

extension NSColor {
    //Only rgb color space
    public static func rgba2rgb(background: NSColor, color: NSColor) -> NSColor {
        let bgCg = background.cgColor
        let colorCg = color.cgColor
        let alpha = colorCg.alpha
        
        return NSColor(red: (1 - alpha) * bgCg.components![0] + colorCg.components![0],
                       green: (1 - alpha) * bgCg.components![1] + colorCg.components![1],
                       blue: (1 - alpha) * bgCg.components![2] + colorCg.components![2],
                       alpha: 1.0)
    }
    
    public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public convenience init(hex8: UInt32) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >>  8) / divisor
        let alpha   = CGFloat( hex8 & 0x000000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

