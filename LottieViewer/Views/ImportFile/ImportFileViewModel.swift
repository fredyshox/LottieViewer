//
//  ContentViewModel.swift
//  AppleVideoOverlay
//
//  Created by Kacper Rączy on 08/08/2020.
//  Copyright © 2020 Kacper Rączy. All rights reserved.
//

import AppKit
import SwiftUI
import AVFoundation

class ImportFileViewModel: NSObject, ObservableObject, NSUserInterfaceValidations, NSMenuItemValidation {
    private(set) weak var window: NSWindow?
    private(set) var stateBinding: Binding<MainWindowController.State>
    var allowedFileTypes: [String] {
        return [
            UTType.json.identifier,
        ]
    }
    
    init(window: NSWindow?, stateBinding: Binding<MainWindowController.State>) {
        self.window = window
        self.stateBinding = stateBinding
    }
    
    func importFile(from url: URL) {
        stateBinding.wrappedValue = .preview(url: url)
    }
    
    func onAppear() {
        window?.styleMask.remove(.resizable)
    }
    
    @objc func presentOpenPanel() {
        guard let window = window else {
            NSLog("\(type(of: self)) window nil.")
            return
        }
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.worksWhenModal = true
        panel.canChooseDirectories = false
        panel.resolvesAliases = true
        panel.allowedFileTypes = allowedFileTypes
        
        panel.beginSheetModal(for: window) { (response) in
            if response == .OK, let url = panel.url {
                NSLog("NSOpenPanel OK \(url)")
                NSDocumentController.shared.noteNewRecentDocumentURL(url)
                DispatchQueue.main.async {
                    self.importFile(from: url)
                }
            }
        }
    }
    
    // MARK: NSUserInterfaceValidations
    
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if window?.attachedSheet != nil {
            return false
        }
        
        switch stateBinding.wrappedValue {
        case .preview, .none:
            return false
        default:
            return true
        }
    }
    
    // MARK: NSMenuItemValidation
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(presentOpenPanel) {
            return true
        }
        
        return false
    }
}
