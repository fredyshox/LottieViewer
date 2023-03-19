//
//  PreviewViewModel.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 06/04/2022.
//

import Foundation
import Combine
import CoreGraphics
import Lottie

final class PreviewViewModel: ObservableObject {
    private enum Constants {
        static let initialWindowSize = CGSize(width: 800, height: 600)
        static let minimumWindowSize = CGSize(width: 600, height: 400)
        static let margin: CGFloat = 100
    }
    
    let animation: LottieAnimation
    // progress conducted by user interaction with playback control, this is received
    @Published var interactionProgress: CGFloat = 0.0
    // progress for playback control, this is published
    @Published var playbackControlProgress: CGFloat = 0.0
    // realtime progress for animation, this is received
    @Published var animationProgress: CGFloat = 0.0
    @Published var currentTimeString: String = ""
    @Published var durationString: String = ""
    @Published var backgroundColor: NSColor = .clear
    @Published var isPlaying: Bool = true
    @Published var isLoopOn: Bool = true
    @Published var isUserInteracting: Bool = false
    @Published var inspectorPresented: Bool = false
    
    var initialWindowSize: CGSize {
        Constants.initialWindowSize
    }
    var minimumWindowSize: CGSize {
        Constants.minimumWindowSize
    }
    
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    private let colorPanel = RGBColorPanel()
    private var cancellableSet = Set<AnyCancellable>()
    private var wasPlaying: Bool = true
    
    convenience init?(url: URL) {
        guard let animation = LottieAnimation.filepath(url.path) else {
            return nil
        }
        
        self.init(animation: animation)
    }
    
    convenience init?(animationName: String) {
        guard let animation = LottieAnimation.named(animationName) else {
            return nil
        }
        
        self.init(animation: animation)
    }
    
    init(animation: LottieAnimation) {
        self.animation = animation
        setup()
    }
    
    private func setup() {
        durationString = timeFormatter.string(from: animation.duration) ?? ""
        $animationProgress
            .map { [animation, timeFormatter] progress in
                let currentTime = floor(animation.duration * progress)
                return timeFormatter.string(from: currentTime) ?? ""
            }
            .assign(to: &$currentTimeString)
        
        $isUserInteracting
            .dropFirst()
            .sink { [weak self] interaction in
                guard let self = self else {
                    return
                }
                
                if interaction {
                    self.wasPlaying = self.isPlaying
                    self.isPlaying = false
                } else {
                    self.isPlaying = self.wasPlaying
                }
            }
            .store(in: &cancellableSet)
        
        Publishers.CombineLatest($interactionProgress.dropFirst(), $isUserInteracting)
            .filter { $0.1 }
            .map { $0.0 }
            .assignNoRetain(to: \.playbackControlProgress, on: self)
            .store(in: &cancellableSet)

        Publishers.CombineLatest($animationProgress, $isUserInteracting)
            .filter { !$0.1 }
            .map { $0.0 }
            .assignNoRetain(to: \.playbackControlProgress, on: self)
            .store(in: &cancellableSet)
        
        colorPanel.colorPublisher
            .assign(to: &$backgroundColor)
    }
    
    func onPickColor() {
        colorPanel.color = backgroundColor
        colorPanel.show()
    }
    
    func onShowInfo() {
        inspectorPresented = true
    }
    
    func onWindowClose() {
        inspectorPresented = false
        isPlaying = false
        colorPanel.hide()
    }
}
