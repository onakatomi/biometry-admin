//
//  ContentView.swift
//  Biometry
//
//  Created by Nakatomi on 15/7/2025.
//
//  Declares whats shown on the GUI, binds to properties from View Model but doesn't contain heavy logic
//

import SwiftUI
import AVKit

struct ContentView: View {
    @ObservedObject var viewModel: VideoPlaybackViewModel
    
    var body: some View {
        ZStack {
            Color(.darkGray).ignoresSafeArea() // Admin panel background colour
            VStack(spacing: 16) {
                Header()
                
                InlinePreviewView(players: viewModel.previewVideoPlayers)
                
                // Select files button -- only show if we're not in playback mode
                if (!viewModel.areVideosPlaying) {
                    PrimaryButton(text: viewModel.videoUrls.isEmpty ? "Choose files" : "Replace files") { viewModel.selectVideos() }
                }
                
                // List of screens available for playback with their info
                ScreenSelectionView(screens: viewModel.model.screens, cgDisplayIDs: viewModel.model.cgDisplayIDs, selectedVideoForScreen: $viewModel.selectedVideoForScreen, videoCount: viewModel.videoUrls.count)
                
                // If we're not currently playing a video and we have at least 1 video to show.
                if viewModel.areVideosPlaying {
                    PrimaryButton(text: "Stop playback") { viewModel.stopPlayback() }
                } else {
                    PrimaryButton(text: "Start experience!") { viewModel.startPlayback() }
                }
            }
            // Rebuild player array whenever the user picks new files (which triggers videoUrls to update)
            .onChange(of: viewModel.videoUrls) { viewModel.updatePlayers() }
            // Keep list of screen-to-video mappings in-sync when screens change
            .onChange(of: viewModel.model.screens) { viewModel.resetSelections() }
        }
    }
}

#Preview {
    ContentView(viewModel: VideoPlaybackViewModel())
}
