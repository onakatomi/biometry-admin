//
//  ContentView.swift
//  Biometry
//
//  Created by Nakatomi on 15/7/2025.
//
//  Declares whats shown on the GUI, binds to properties from View Model but doesn't contain heavy logic.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @ObservedObject var viewModel: VideoPlaybackViewModel
    @StateObject private var vm = SpeechViewModel()
    
    var body: some View {
        ZStack {
            Color(.darkGray).ignoresSafeArea() // Admin panel background colour
            VStack(spacing: 20) {
                Header()
                
                InlinePreviewView(
                    players: viewModel.previewVideoPlayers,
                    screens: viewModel.model.screens,
                    selectedScreenForVideos: $viewModel.selectedScreenForVideos
                )
                
                // Select files button -- only enable if we're not in playback mode
                PrimaryButton(
                    text: viewModel.videoUrls.isEmpty ? "Select videos" : "Replace videos",
                    disabled: viewModel.areVideosPlaying,
                    handler: viewModel.selectVideos
                )
                
                // Audio file
                if (viewModel.audioPlayer == nil) {
                    PrimaryButton(
                        text: "Select audio",
                        disabled: viewModel.areVideosPlaying,
                        color: .green,
                        handler: viewModel.selectAudioFile
                    )
                } else {
                    Text("Uploaded audio file: \(String(describing: viewModel.audioPlayer?.data))")
                        .font(.system(size: 10))
                }
                
                // List of screens available for playback with their info
                ScreenSelectionView(
                    screens: viewModel.model.screens,
                    cgDisplayIDs: viewModel.model.cgDisplayIDs
                )
                
                // If we're not currently playing a video and we have at least 1 video to show.
                if viewModel.areVideosPlaying {
                    PrimaryButton(
                        text: "Stop",
                        handler: viewModel.stopPlayback
                    )
                } else {
                    PrimaryButton(
                        text: "Play!",
                        disabled: !viewModel.videosReadyForPlayback(),
                        handler: viewModel.startPlayback
                    )
                }
                
                // Refresh screens
                PrimaryButton(
                    text: "Refresh screens",
                    handler: viewModel.model.reload
                )
                
                // LLM
                PrimaryButton(text: "Query") {
                    let url = URL(string: "http://127.0.0.1:3000/generate")!
                    let newRequest = LLMQuery(query: "Who is Elon Musk?")
                    let bodyData = try JSONEncoder().encode(newRequest)

                   let response: LLMResponse = try await ApiService.shared.request(
                        url: url,
                        method: .POST,
                        body: bodyData
                    )

                    print("LLM Response:", response)
                }
            }
            // Rebuild player array whenever the user picks new files (which triggers videoUrls to update)
            .onChange(of: viewModel.videoUrls) { viewModel.updatePlayers() }
            // Keep list of screen-to-video mappings in-sync when screens change
            .onChange(of: viewModel.model.screens) { viewModel.resetSelections() }
            .padding()
        }
    }
}

#Preview {
    ContentView(viewModel: VideoPlaybackViewModel())
}
