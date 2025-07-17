//
//  ContentView.swift
//  Biometry
//
//  Created by Nakatomi on 15/7/2025.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @State private var videoUrls: [URL] = [] // Videos selected.
    @State private var externalScreenVideoPlayers: [AVPlayer] = [] // Active list of players (each corresponding to a video)
    @State private var previewVideoPlayers: [AVPlayer] = [] // Video players for inline preview
    @State private var screenWindows: [NSWindow] = [] // Keep track of screens currently in playback
    @State private var areVideosPlaying = false // Whether we're currently in playback
    @State private var selectedVideoForScreen: [Int?] = [] // one selected-video index per screen; default to 0
    @StateObject private var model = DisplayModel() // Model giving us screen info
    
    var body: some View {
        ZStack {
            // Admin panel background colour
            Color(.darkGray)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "toilet")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundStyle(.tint)
                Text("Welcome to Biometry!")
                    .bold()
                    .font(.title)
                
                // In-line preview of selected videos.
                if !videoUrls.isEmpty {
                    HStack {
                        ForEach(previewVideoPlayers.indices, id: \.self) { i in
                            let player = previewVideoPlayers[i]
                            VideoPlayer(player: player)
                                .frame(height: 100)
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                                .onAppear { player.play() }
                        }
                    }
                } else { Text("Pick some videos to preview...") }
                
                // Select files button
                PrimaryButton(text: videoUrls.isEmpty ? "Choose files" : "Replace files") {
                    selectVideos()
                }
                
                // List of screens available for playback with their info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available screens:")
                        .font(.headline)
                    
                    ForEach(model.screens.indices, id: \.self) { i in
                        HStack(spacing: 16) {
                            let cgDisplayId = model.cgDisplayIDs[i]
                            let mode = CGDisplayCopyDisplayMode(cgDisplayId)
                            Text("Screen \(i+1): \(mode?.pixelWidth ?? 0)×\(mode?.pixelHeight ?? 0)")
                                .buttonStyle(.bordered)
                            
                            // Next to each video we have a dropdown of available videos we want to play on each screen
                            if selectedVideoForScreen.indices.contains(i) {
                                Picker("Video", selection: $selectedVideoForScreen[i]) {
                                    Text("None")
                                        .tag(nil as Int?)
                                    ForEach(videoUrls.indices, id: \.self) { vid in
                                        Text("Video \(vid+1)")
                                            .tag(Optional(vid))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: 120)
                            }
                            
                        }
                    }
                }
                .padding(.top)
                
                // If we're not currently playing a video and we have at least 1 video to show.
                if (!areVideosPlaying) {
                    PrimaryButton(text: "Start experience!") {
                        areVideosPlaying = true
                        launchOnScreens()
                    }
                } else {
                    PrimaryButton(text: "Stop playback") { stopPlayback() }
                }
            }
            // Rebuild player array whenever the user picks new files (which triggers videoUrls to update)
            .onChange(of: videoUrls) { _, newUrls in
                externalScreenVideoPlayers = newUrls.map { AVPlayer(url: $0) }
                previewVideoPlayers = newUrls.map { AVPlayer(url: $0) }
                
                // Reset selections when the videos change
                selectedVideoForScreen = Array(
                    repeating: nil,
                    count: model.screens.count
                )
            }
            // Keep list of screen-to-video mappings in-sync when screens change
            .onChange(of: model.screens) { _, screens in
                selectedVideoForScreen = Array(
                    repeating: nil,
                    count: screens.count
                )
            }
        }
    }
    
    // Open the native file picker to select videos to playback
    private func selectVideos() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.video, .movie]
        panel.allowsMultipleSelection = true
        panel.begin { resp in
            guard resp == .OK else { return }
            videoUrls = panel.urls
        }
    }
    
    // Play videos to selected screens!
    private func launchOnScreens() {
        screenWindows.removeAll()
        for (screenIndex, videoIndex) in selectedVideoForScreen.enumerated() where screenIndex < model.screens.count {
            if videoIndex == nil { continue } // If a screen doesn't have a video, skip over it as we have nothing to launch to it.
            let screen = model.screens[screenIndex] // Retrieve screen object to play corresponding video on
            
            // Make a brand-new window on that screen
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            
            // Set AV settings
            let avView = AVPlayerView(frame: screen.frame)
            avView.player = externalScreenVideoPlayers[videoIndex!]
            avView.player?.seek(to: .zero) // Play the videos from the start
            avView.player?.play() // Start the video immediately
            avView.controlsStyle = .none // Hide controls
            avView.videoGravity = .resizeAspect
            
            // Set window settings
            window.setFrame(screen.frame, display: true) // Center on screen and size to fill
            window.level = .screenSaver // Full screen
            window.contentView = avView // Place the AV View into the screen
            window.makeKeyAndOrderFront(nil) // Bring to front
            window.isReleasedWhenClosed = false // Do not immediately deallocate the window object as soon as it’s closed -- gives us full control over its lifeitme
            
            screenWindows.append(window)  // Add this window to list of currently tracked windows
        }
    }
    
    // Stop playback on all screens
    private func stopPlayback() {
        screenWindows.forEach { $0.close() } // Close each window
        screenWindows.removeAll() // Remove all screens from active screens array
        areVideosPlaying = false
    }
    
}

#Preview {
    ContentView()
}
