//
//  AutoNSViewRepresentable.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 24/04/2022.
//

#if DEBUG && canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
struct AutoNSViewRepresentable<Content: NSView>: NSViewRepresentable {
    let nsView: Content
    let configClosure: ((Content) -> Void)?
    
    init(nsView: Content, configClosure: ((Content) -> Void)? = nil) {
        self.nsView = nsView
        self.configClosure = configClosure
    }
    
    func makeNSView(context: Context) -> Content {
        configClosure?(nsView)
        return nsView
    }
    
    func updateNSView(_ nsView: Content, context: Context) {}
}

@available(macOS 10.15, *)
struct AutoNSViewControllerRepresentable<Controller: NSViewController>: NSViewControllerRepresentable {
    let nsViewController: Controller
    let configClosure: ((Controller) -> Void)?
    
    init(nsViewController: Controller, configClosure: ((Controller) -> Void)? = nil) {
        self.nsViewController = nsViewController
        self.configClosure = configClosure
    }
    
    func makeNSViewController(context: Context) -> Controller {
        configClosure?(nsViewController)
        return nsViewController
    }
    
    func updateNSViewController(_ uiViewController: Controller, context: Context) {}
}

#endif
