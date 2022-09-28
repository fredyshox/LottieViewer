//
//  VideoDropNSView.swift
//  AppleVideoOverlay
//
//  Created by Kacper Rączy on 09/08/2020.
//  Copyright © 2020 Kacper Rączy. All rights reserved.
//

import AppKit

class VideoDropNSView: NSView {
    weak var viewModel: ImportFileViewModel?
    private var isDragActive: Bool = false {
        didSet {
            if isDragActive {
                layer?.borderWidth = 4.0
            } else {
                layer?.borderWidth = 0.0
            }
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wantsLayer = true
        autoresizingMask = [.width, .height]
        registerForDraggedTypes(supportedDraggingTypes)
        layer?.borderColor = NSColor.controlAccentColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var supportedDraggingTypes: [NSPasteboard.PasteboardType] {
        return [.fileURL]
    }
    
    var supportedContentTypes: [String] {
        return viewModel?.allowedFileTypes ?? []
    }
    
    var pasteboardReadingOptions: [NSPasteboard.ReadingOptionKey: Any] {
        return [
            .urlReadingFileURLsOnly: true,
            .urlReadingContentsConformToTypes: supportedContentTypes
        ]
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pboard = sender.draggingPasteboard
        // dragged object must be fileurl and conform to movie type
        guard let urls = pboard.readObjects(forClasses: [NSURL.self], options: pasteboardReadingOptions) as? [URL], urls.count == 1 else {
            // none
            return []
        }
        
        guard sender.draggingSourceOperationMask.contains(.copy) else {
            // none
            return []
        }
        
        isDragActive = true
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDragActive = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isDragActive = false
        
        let pboard = sender.draggingPasteboard
        guard let url = pboard.readObjects(forClasses: [NSURL.self], options: pasteboardReadingOptions)?.first as? URL else {
            return false
        }
        
        viewModel?.importFile(from: url)
        return true
    }
}
