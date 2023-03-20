//
//  MainWindowController.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 06/04/2022.
//

import AppKit
import SwiftUI

final class MainWindowController: NSWindowController, NSWindowDelegate {
    enum IOError: LocalizedError {
        case unableToParse(URL)
        
        var errorDescription: String? {
            switch self {
            case .unableToParse(let url):
                return "File at \(url.path) does not contain valid lottie animation."
            }
        }
    }
    
    enum State {
        case none
        case main
        case preview(url: URL)
    }
    
    static let importFileStyleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
    static let previewStyleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView, .resizable]
    
    static let importFileViewSize: NSSize = NSSize(width: 360.0, height: 240.0)
    static let previewViewSize: NSSize = NSSize(width: 800.0, height: 500.0)
    
    private weak var openMenuItem: NSMenuItem?
    private var importFileViewModel: ImportFileViewModel!
    private var state: State = .main {
        didSet {
            presentView(using: state)
        }
    }
    
    var stateBinding: Binding<State> {
        return Binding(get: { [weak self] in
            return self?.state ?? .none
        }, set: { [weak self] (newValue) in
            self?.state = newValue
        })
    }
    
    init(menuItem: NSMenuItem?) {
        openMenuItem = menuItem
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: MainWindowController.importFileViewSize),
            styleMask:  MainWindowController.importFileStyleMask,
            backing: .buffered, defer: false
        )
        window.backingType = .buffered
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.setFrameAutosaveName("\(type(of: self))")
        super.init(window: window)
        window.delegate = self
        
        importFileViewModel = ImportFileViewModel(window: window, stateBinding: stateBinding)
        openMenuItem?.target = importFileViewModel
        openMenuItem?.action = #selector(importFileViewModel.presentOpenPanel)
        openMenuItem?.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showImportView() {
        state = .main
        window?.center()
        showWindow(nil)
    }
    
    func unminiutarizeOrShowImportView() {
        guard let window else {
            return
        }
        
        if window.isMiniaturized {
            window.setIsMiniaturized(false)
        } else if !window.isVisible {
            showImportView()
        }
    }
    
    func open(url: URL) {
        state = .preview(url: url)
        showWindow(nil)
    }
    
    private func presentView(using state: State) {
        switch state {
        case .main:
            presentImportView()
        case .preview(let url):
            presentPreview(with: url)
        default:
            resetWindowState()
        }
    }
    
    private func presentImportView() {
        window?.contentView = nil
        window?.contentViewController = nil
        window?.titleVisibility = .hidden
        window?.title = ""
        window?.styleMask = MainWindowController.importFileStyleMask
        window?.animatedResize(to: MainWindowController.importFileViewSize)
        
        let importView = ImportFileView(
            windowSize: MainWindowController.importFileViewSize, viewModel: importFileViewModel
        )
        let contentView = NSHostingView(rootView: importView)
        contentView.animateOpacityChange()
        window?.contentView = contentView
    }
    
    private func presentPreview(with url: URL) {
        guard let viewModel = PreviewViewModel(url: url) else {
            presentError(IOError.unableToParse(url))
            return
        }
        
        window?.contentView = nil
        window?.contentViewController = nil
        window?.titleVisibility = .visible
        window?.title = url.lastPathComponent
        window?.styleMask = MainWindowController.previewStyleMask
        window?.minSize = viewModel.minimumWindowSize
        window?.animatedResize(to: viewModel.initialWindowSize)
        // handle size
        let contentView = PreviewView(viewModel: viewModel)
        contentView.animateOpacityChange()
        window?.contentView = contentView
    }
    
    private func resetWindowState() {
        window?.contentView = nil
        window?.contentViewController = nil
    }
    
    // MARK: NSWindowDelegate
    
    func window(_ window: NSWindow, willPositionSheet sheet: NSWindow, using rect: NSRect) -> NSRect {
        if #available(macOS 11, *) {
            return rect
        }
        
        if window.styleMask.contains(.fullSizeContentView) {
            return rect.offsetBy(dx: 0.0, dy: -window.titlebarHeight)
        }
        
        return rect
    }
    
    func windowWillClose(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .none
        }
    }
}

extension NSView {
    func animateOpacityChange(duration: Double = 0.5) {
        alphaValue = 0.0
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = duration
            self.animator().alphaValue = 1.0
        })
    }
}

extension NSViewController {
    func animateOpacityChange(duration: Double = 0.5) {
        self.view.animateOpacityChange(duration: duration)
    }
}

extension NSWindow {
    func animatedResize(to size: NSSize) {
        let x = frame.minX - (size.width - frame.width) / 2
        let y = frame.minY - (size.height - frame.height) / 2
        let newFrame = NSRect(origin: CGPoint(x: x, y: y), size: size)
        setFrame(newFrame, display: true, animate: true)
    }
    
    var titlebarHeight: CGFloat {
        let titleBarView = standardWindowButton(.closeButton)?.superview?.superview
        
        return titleBarView?.bounds.height ?? 0.0
    }
}
