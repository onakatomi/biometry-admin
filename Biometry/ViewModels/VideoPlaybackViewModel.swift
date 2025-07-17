//
//  VideoPlaybackViewModel.swift
//  Biometry
//
//  Created by Nakatomi on 17/7/2025.
//
//  Acts as the bridge between the models (display model) and views that needs it. Exposes the properties and methods that views can bind to and use.
//  Updates published properties that views will monitor to automatically redraw if neccessary.
//

import SwiftUI
import AVKit
import AppKit

class VideoPlaybackViewModel: ObservableObject {
    @Published var videoUrls: [URL] = [] // Videos selected.
    @Published var externalScreenVideoPlayers: [AVPlayer] = [] // Active list of players (each corresponding to a video)
    @Published var previewVideoPlayers: [AVPlayer] = [] // Video players for inline preview
    @Published var selectedVideoForScreen: [Int?] = [] // one selected-video index per screen; default to 0
    @Published var areVideosPlaying = false // Whether we're currently in playback
    
    private var screenWindows: [NSWindow] = [] // Keep track of screens currently in playback
    let model = DisplayModel() // Model giving us screen info
    
    func selectVideos() {
        VideoPicker.pickVideos { [weak self] urls in
            DispatchQueue.main.async {
                self?.videoUrls = urls
            }
        }
    }
    
    func updatePlayers() {
        previewVideoPlayers = videoUrls.map { AVPlayer(url: $0) }
        externalScreenVideoPlayers = videoUrls.map { AVPlayer(url: $0) }
        selectedVideoForScreen = Array(repeating: nil, count: model.screens.count) // Reset selections when the videos change
    }
    
    func resetSelections() {
        selectedVideoForScreen = Array(repeating: nil, count: model.screens.count) // Reset selections when the screens change
    }
    
    func startPlayback() {
        areVideosPlaying = true
        launchOnScreens()
    }
    
    private func launchOnScreens() {
        // First to be safe let's clean the slate
        screenWindows.forEach { $0.close() }
        screenWindows.removeAll()
        
        // Launch each video to the corresponding screen
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
    
    func stopPlayback() {
        screenWindows.forEach { $0.close() }
        screenWindows.removeAll()
        areVideosPlaying = false
    }
}
