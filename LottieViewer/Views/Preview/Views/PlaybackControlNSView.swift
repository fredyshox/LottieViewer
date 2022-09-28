//
//  PlaybackControlNSView.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 24/04/2022.
//

import AppKit
import Combine
import SwiftUI

final class PlaybackControlNSView: NSView {
    private enum Constants {
        static let lightGrayColor = NSColor(hex6: 0xdbdcde)
        static let height: CGFloat = 44.0
    }
    
    struct Callbacks {
        let loopModeSubject = PassthroughSubject<Void, Never>()
        let isPlayingSubject = PassthroughSubject<Void, Never>()
        let userInteractionSubject = PassthroughSubject<Bool, Never>()
        let controlProgressSubject = PassthroughSubject<CGFloat, Never>()
    }
    
    let callbacks = Callbacks()
    var isPlaying: Bool = false {
        didSet {
            updateImages()
        }
    }
    var isLoopMode: Bool = false {
        didSet {
            updateImages()
        }
    }
    var playbackProgress: CGFloat {
        get {
            slider.sliderProgress
        }
        set {
            slider.sliderProgress = newValue
        }
    }
    var isUserInteracting: Bool {
        get {
            slider.userInteraction
        }
    }
    
    private let backgroundView = NSVisualEffectView()
    private let slider = Slider()
    private let playButton = NSButton()
    private let loopButton = NSButton()
    
    override init(frame frameRect: NSRect = .zero) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        wantsLayer = true
        
        backgroundView.material = .popover
        backgroundView.blendingMode = .withinWindow
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 8.0
        
        let playSymbolConfiguration = NSImage.SymbolConfiguration(pointSize: 20.0, weight: .regular)
        playButton.imagePosition = .imageOnly
        playButton.isBordered = false
        playButton.symbolConfiguration = playSymbolConfiguration
        playButton.target = self
        playButton.action = #selector(playButtonClicked)
        
        let loopSymbolConfiguration = NSImage.SymbolConfiguration(pointSize: 16.0, weight: .regular)
        loopButton.imagePosition = .imageOnly
        loopButton.isBordered = false
        loopButton.symbolConfiguration = loopSymbolConfiguration
        loopButton.target = self
        loopButton.action = #selector(loopButtonClicked)
        
        slider.reportedProgressDidChange = { [weak self] newProgress in
            self?.callbacks.controlProgressSubject.send(newProgress)
        }
        slider.userInteractionDidChange = { [weak self] interaction in
            self?.callbacks.userInteractionSubject.send(interaction)
        }
        
        makeLayout()
        updateImages()
    }
    
    private func makeLayout() {
        addSubview(backgroundView)
        [slider, playButton, loopButton].forEach(addSubview)
        
        snp.makeConstraints {
            $0.height.equalTo(Constants.height)
        }
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        playButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(12.0)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        slider.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(playButton.snp.right).offset(16.0)
        }
        loopButton.snp.makeConstraints { make in
            make.left.equalTo(slider.snp.right).offset(16.0)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12.0)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        loopButton.rotate(byDegrees: 90.0)
    }
    
    private func updateImages() {
        loopButton.image = NSImage(systemSymbolName: "arrow.triangle.capsulepath", accessibilityDescription: nil)
        playButton.contentTintColor = Constants.lightGrayColor
        if isPlaying {
            playButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: nil)
        } else {
            playButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: nil)
        }
        if isLoopMode {
            loopButton.contentTintColor = NSColor(Color.blue)
        } else {
            loopButton.contentTintColor = Constants.lightGrayColor
        }
    }
    
    @objc private func playButtonClicked(_ sender: NSButton) {
        callbacks.isPlayingSubject.send()
    }
    
    @objc private func loopButtonClicked(_ sender: NSButton) {
        callbacks.loopModeSubject.send()
    }
}

extension PlaybackControlNSView {
    private final class Slider: NSView {
        private enum Constants {
            static let markerSize = CGSize(width: 4.0, height: 16.0)
            static let progressHeight: CGFloat = 4.0
            static let progressBackgroundColor = NSColor(hex6: 0x5f6062)
            static let markerColor = NSColor(hex6: 0xdbdcde)
        }
        
        var reportedProgressDidChange: ((CGFloat) -> Void)?
        var userInteractionDidChange: ((Bool) -> Void)?
        
        var userInteraction: Bool = false {
            didSet {
                userInteractionDidChange?(userInteraction)
            }
        }
        var reportedProgress: CGFloat = 0.0 {
            didSet {
                reportedProgressDidChange?(reportedProgress)
            }
        }
        var sliderProgress: CGFloat = 0.0 {
            didSet {
                setNeedsDisplay(bounds)
            }
        }
        
        override var isFlipped: Bool { true }
        
        override init(frame frameRect: NSRect = .zero) {
            super.init(frame: frameRect)
            
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            let panGesture = NSPanGestureRecognizer(target: self, action: #selector(handleGesture(gestureRecognizer:)))
            
            let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleGesture(gestureRecognizer:)))
            
            addGestureRecognizer(panGesture)
            addGestureRecognizer(clickGesture)
        }
        
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            
            let progressFrame = NSRect(
                x: Constants.markerSize.width/2, y: dirtyRect.midY - Constants.progressHeight/2,
                width: dirtyRect.width - Constants.markerSize.width, height: Constants.progressHeight
            )
            let progressPath = NSBezierPath(roundedRect: progressFrame, xRadius: 2.0, yRadius: 2.0)
            Constants.progressBackgroundColor.setFill()
            progressPath.fill()
            
            let markerFrame = NSRect(
                origin: CGPoint(
                    x: Constants.markerSize.width/2 + sliderProgress*(dirtyRect.width - 1.5*Constants.markerSize.width),
                    y: dirtyRect.midY - Constants.markerSize.height/2
                ),
                size: Constants.markerSize
            )
            let markerPath = NSBezierPath(roundedRect: markerFrame, xRadius: 2.0, yRadius: 2.0)
            Constants.markerColor.setFill()
            markerPath.fill()
        }
        
        @objc private func handleGesture(gestureRecognizer: NSGestureRecognizer) {
            let location = gestureRecognizer.location(in: self)
            if gestureRecognizer is NSClickGestureRecognizer {
                switch gestureRecognizer.state {
                case .ended:
                    userInteraction = true
                    let progress = max(0.0, min(1.0, location.x / bounds.width))
                    reportedProgress = progress
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.userInteraction = false
                    }
                default:
                    break
                }
            } else if gestureRecognizer is NSPanGestureRecognizer {
                switch gestureRecognizer.state {
                case .began:
                    userInteraction = true
                    fallthrough
                case .changed:
                    let progress = max(0.0, min(1.0, location.x / bounds.width))
                    reportedProgress = progress
                default:
                    userInteraction = false
                }
            }
            setNeedsDisplay(bounds)
        }
    }
}

struct PlaybackControlNSView_Previews: PreviewProvider {
    static var previews: some View {
        AutoNSViewRepresentable(nsView: PlaybackControlNSView())
            .background(Color.red)
    }
}
