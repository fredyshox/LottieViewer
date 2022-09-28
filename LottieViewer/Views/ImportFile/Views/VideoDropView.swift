//
//  VideoDropView.swift
//  AppleVideoOverlay
//
//  Created by Kacper Rączy on 09/08/2020.
//  Copyright © 2020 Kacper Rączy. All rights reserved.
//

import SwiftUI

struct VideoDropView: NSViewRepresentable {
    weak var viewModel: ImportFileViewModel?
    
    init(viewModel: ImportFileViewModel?) {
        self.viewModel = viewModel
    }
    
    func makeNSView(context: Context) -> VideoDropNSView {
        let videoDropView = VideoDropNSView()
        videoDropView.viewModel = viewModel
        
        return videoDropView
    }
    
    func updateNSView(_ nsView: VideoDropNSView, context: Context) {}
}

struct VideoDropView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDropView(viewModel: nil)
    }
}
