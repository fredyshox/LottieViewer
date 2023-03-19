//
//  ThumbnailProvider.swift
//  ThumbnailExtension
//
//  Created by Kacper Rączy on 16/03/2023.
//

import QuickLookThumbnailing
import Lottie

class ThumbnailProvider: QLThumbnailProvider {
    private enum Constants {
        static let maxFileSize: UInt64 = 500_000
    }
    
    enum IOError: Error {
        case statFailure
        case fileTooLarge
    }
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        do {
            NSLog("Received thumbnail request for \(request.fileURL)")
            let animation = try parseAnimation(at: request.fileURL)
            let reply = QLThumbnailReply(contextSize: request.maximumSize) {
                self.generateThumbnailFromFirstFrame(animation: animation, size: request.maximumSize)
                return true
            }
            
            handler(reply, nil)
        } catch let error {
            NSLog("Error while generating a thumbnail: \(error)")
            handler(nil, error)
        }
    }
    
    private func parseAnimation(at url: URL) throws -> LottieAnimation {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let size = attributes[.size] as? UInt64, size != .zero else {
            throw IOError.statFailure
        }
        
        guard size < Constants.maxFileSize else {
            throw IOError.fileTooLarge
        }
        
        let data = try Data(contentsOf: url)
        let animation = try LottieAnimation.from(data: data)
        
        return animation
    }
    
    private func generateThumbnailFromFirstFrame(animation: LottieAnimation, size: CGSize) {
        guard let context = NSGraphicsContext.current else {
            return
        }
        
        let frame = CGRect(origin: .zero, size: size)
        let configuration = LottieConfiguration(renderingEngine: .mainThread)
        let view = LottieAnimationView(configuration: configuration)
        view.frame = frame
        view.animation = animation
        view.backgroundBehavior = .pause
        view.contentMode = .scaleAspectFit
        view.currentProgress = 0.5
        view.forceDisplayUpdate()
        view.displayIgnoringOpacity(frame, in: context)
    }
}
