//
//  ContentView.swift
//  AppleVideoOverlay
//
//  Created by Kacper Rączy on 26/07/2020.
//  Copyright © 2020 Kacper Rączy. All rights reserved.
//

import SwiftUI

struct ImportFileView: View {
    let windowSize: CGSize
    @ObservedObject var viewModel: ImportFileViewModel
    
    var body: some View {
        VStack(spacing: 6.0) {
            Text("Drop a lottie")
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text("or")
                .fontWeight(.light)
                .foregroundColor(.secondary)
            Button(action: {
                self.viewModel.presentOpenPanel()
            }) {
                Text("Open")
                    .foregroundColor(.secondary)
            }
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ImportFileViewBackground(windowSize: windowSize, viewModel: viewModel)
            )
            .onAppear() {
                viewModel.onAppear()
            }
    }
}

struct ImportFileViewBackground: View {
    let windowSize: CGSize
    weak var viewModel: ImportFileViewModel?
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .titlebar,
                             blendingMode: .behindWindow,
                             state: .active)
            Image("background")
            VideoDropView(viewModel: viewModel)
                .frame(width: windowSize.width, height: windowSize.height) // nsview is not sized correctly so, we need this...
        }
            .edgesIgnoringSafeArea(.all)
    }
}

struct ImportFileView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ImportFileViewModel(window: nil, stateBinding: .constant(.none))
        return ImportFileView(windowSize: CGSize(width: 360, height: 240), viewModel: viewModel)
    }
}
