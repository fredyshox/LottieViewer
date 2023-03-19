//
//  InfoInspectorViewModel.swift
//  LottieViewer
//
//  Created by Kacper Rączy on 24/04/2022.
//

import Foundation
import Lottie

final class InfoInspectorViewModel: ObservableObject {
    enum Cells {
        case source
        case type
        case framerate
        case size
        case duration
        
        var localizedTitle: String {
            switch self {
            case .source:
                return "Source:"
            case .type:
                return "Type:"
            case .size:
                return "Resolution:"
            case .framerate:
                return "Frame rate:"
            case .duration:
                return "Duration:"
            }
        }
    }
    
    private let animation: LottieAnimation
    
    @Published var cells: [(Cells, String)] = []
    
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
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.allowedUnits = [.hour, .minute, .second]
        durationFormatter.unitsStyle = .abbreviated
        cells = [
            (.size, "\(Int(animation.size.width)) × \(Int(animation.size.height))"),
            (.framerate, String(format: "%.2f fps", animation.framerate)),
            (.duration, durationFormatter.string(from: animation.duration) ?? "")
        ]
    }
}
