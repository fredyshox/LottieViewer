//
//  ButtonStack.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 24/04/2022.
//

import AppKit

final class ButtonStack: NSView {
    var onInfo: (() -> Void)?
    var onStyle: (() -> Void)?
    
    private let backgroundView = NSVisualEffectView()
    private lazy var styleButton: NSButton = {
        let brushImage = NSImage(systemSymbolName: "paintbrush.pointed.fill", accessibilityDescription: "pick background color")!
        let button = NSButton(image: brushImage, target: self, action: #selector(styleButtonClicked))
        
        return button
    }()
    private lazy var infoButton: NSButton = {
        let image = NSImage(systemSymbolName: "info", accessibilityDescription: "show file info")!
        let button = NSButton(image: image, target: self, action: #selector(infoButtonClicked))
        
        return button
    }()
    
    override init(frame frameRect: NSRect = .zero) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundView.material = .popover
        backgroundView.blendingMode = .withinWindow
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 8.0
        
        makeLayout()
    }
    
    private func makeLayout() {
        let stack = NSStackView(views: [infoButton, styleButton])
        stack.spacing = 8.0
        stack.orientation = .vertical
        stack.distribution = .fillEqually
        
        addSubview(backgroundView)
        addSubview(stack)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8.0)
        }
        infoButton.snp.makeConstraints { make in
            make.width.equalTo(styleButton)
        }
    }
    
    @objc private func infoButtonClicked() {
        onInfo?()
    }
    
    @objc private func styleButtonClicked() {
        onStyle?()
    }
}
