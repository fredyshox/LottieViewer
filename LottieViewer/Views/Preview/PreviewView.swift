//
//  PreviewView.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 06/04/2022.
//

import AppKit
import Lottie
import SnapKit
import SwiftUI
import Combine

final class PreviewView: NSView {
    private enum Constants {
        static let progressUpdateInterval = 1.0/60.0
    }
    
    let viewModel: PreviewViewModel
    let inspectorPanel = NSPanel()

    private let scrollView = NSScrollView()
    private let containerView = NSView()
    private let animationView = AnimationView()
    private let controlView = PlaybackControlNSView()
    private let buttons = ButtonStack()
    
    private var cancellableSet: Set<AnyCancellable> = Set()
    private var windowObservation: NSObjectProtocol?
    
    deinit {
        guard let observation = windowObservation else {
            return
        }
        
        NotificationCenter.default.removeObserver(observation)
    }
    
    init(viewModel: PreviewViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setup()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        animationView.animation = viewModel.animation
        inspectorPanel.contentView = InfoInspectorView(
            viewModel: InfoInspectorViewModel(
                animation: viewModel.animation
            )
        )
        
        // frame timer
        Timer.publish(
            every: Constants.progressUpdateInterval,
            on: .main,
            in: .common
        )
            .autoconnect()
            .map { [weak animationView] _ in 
                animationView?.realtimeAnimationProgress ?? 0.0
            }
            .assign(to: &viewModel.$animationProgress)
        
        // control view callbacks
        controlView.callbacks.isPlayingSubject
            .sink { [weak viewModel] in
                viewModel?.isPlaying.toggle()
            }
            .store(in: &cancellableSet)
        controlView.callbacks.loopModeSubject
            .sink { [weak viewModel] in
                viewModel?.isLoopOn.toggle()
            }
            .store(in: &cancellableSet)
        controlView.callbacks.controlProgressSubject
            .assign(to: &viewModel.$interactionProgress)
        controlView.callbacks.userInteractionSubject
            .assign(to: &viewModel.$isUserInteracting)
        
        // buttons callbacks
        buttons.onStyle = { [weak viewModel] in
            viewModel?.onPickColor()
        }
        buttons.onInfo = { [weak viewModel] in
            viewModel?.onShowInfo()
        }
        
        // view model callbacks
        let animationCompletionBlock: (Bool) -> Void = { [weak viewModel] completed in
            guard completed else { return }
            
            viewModel?.isPlaying = false
        }
        viewModel.$isPlaying
            .assignNoRetain(to: \.isPlaying, on: controlView)
            .store(in: &cancellableSet)
        viewModel.$isPlaying
            .sink { [weak animationView, animationCompletionBlock] isPlaying in
                if isPlaying {
                    animationView?.play(completion: animationCompletionBlock)
                } else {
                    animationView?.pause()
                }
            }
            .store(in: &cancellableSet)
        viewModel.$isLoopOn
            .assignNoRetain(to: \.isLoopMode, on: controlView)
            .store(in: &cancellableSet)
        viewModel.$isLoopOn
            .sink { [weak animationView] loopMode in
                animationView?.loopMode = loopMode ? .loop : .playOnce
            }
            .store(in: &cancellableSet)
        viewModel.$playbackControlProgress
            .assignNoRetain(to: \.playbackProgress, on: controlView)
            .store(in: &cancellableSet)
        viewModel.$interactionProgress
            .dropFirst()
            .sink { [weak animationView] progress in
                animationView?.currentProgress = progress
            }
            .store(in: &cancellableSet)
        viewModel.$backgroundColor
            .assignNoRetain(to: \.backgroundColor, on: scrollView)
            .store(in: &cancellableSet)
        viewModel.$inspectorPresented
            .sink { [weak inspectorPanel] isPresented in
                if isPresented {
                    inspectorPanel?.orderFront(nil)
                    inspectorPanel?.makeKey()
                } else {
                    inspectorPanel?.close()
                }
            }
            .store(in: &cancellableSet)
        windowObservation = NotificationCenter.default
            .addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: .main) { [weak self] notification in
                guard (notification.object as? NSWindow) === self?.window else {
                    return
                }

                self?.viewModel.onWindowClose()
            }
    }
    
    private func setup() {
        wantsLayer = true
        containerView.layerBackgroundColor = .white
        scrollView.contentView.documentView = containerView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        animationView.contentMode = .scaleAspectFit
        
        let trackingArea = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        
        setupInspector()
        
        makeLayout()
    }
    
    private func setupInspector() {
        inspectorPanel.isFloatingPanel = true
        inspectorPanel.level = .floating
        inspectorPanel.collectionBehavior.insert(.fullScreenAuxiliary)
        inspectorPanel.animationBehavior = .utilityWindow
        inspectorPanel.styleMask = [.hudWindow, .utilityWindow, .nonactivatingPanel, .titled, .closable, .fullSizeContentView]
        inspectorPanel.titlebarAppearsTransparent = true
        inspectorPanel.title = "Inspector"
        inspectorPanel.center()
    }
    
    private func makeLayout() {
        addSubview(scrollView)
        addSubview(controlView)
        addSubview(buttons)
        containerView.addSubview(animationView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.height.equalTo(safeAreaLayoutGuide.snp.height)
            make.width.equalTo(safeAreaLayoutGuide.snp.width)
        }
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview().inset(24)
            make.top.bottom.equalToSuperview().inset(48)
            make.left.lessThanOrEqualToSuperview().inset(24)
            make.right.greaterThanOrEqualToSuperview().inset(24)
        }
        controlView.snp.makeConstraints { make in
            make.width.equalTo(500.0)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(32.0)
        }
        buttons.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.right.equalToSuperview().inset(12.0)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            controlView.animator().alphaValue = 1.0
            buttons.animator().alphaValue = 1.0
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            controlView.animator().alphaValue = 0.0
            buttons.animator().alphaValue = 0.0
        }
    }
}

extension NSView {
    var layerBackgroundColor: NSColor? {
        get {
            guard let cgColor = layer?.backgroundColor else {
                return nil
            }
            
            return NSColor(cgColor: cgColor)
        }
        set {
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}
