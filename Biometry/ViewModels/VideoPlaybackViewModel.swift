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
    @Published var videoUrls: [URL] = [] // Videos selected
    // An array of size videoUrls.length which signifies a selected audio file for each video. Optional as can be nil as depends on video array.
    @Published var audioPlayer: AVAudioPlayer?
    @Published var externalScreenVideoPlayers: [AVPlayer] = [] // Active list of players (each corresponding to a video)
    @Published var previewVideoPlayers: [AVPlayer] = [] // Video players for inline preview
    @Published var selectedScreenForVideos: [Int?] = [] // index of screen for each video
    @Published var areVideosPlaying = false // Whether we're currently in playback
    
    private var screenWindows: [NSWindow] = [] // Keep track of screens currently in playback
    let model = DisplayModel() // Model giving us screen info
    
    func selectVideos() {
        MediaPicker.pickVideos { [weak self] urls in
            DispatchQueue.main.async {
                self?.videoUrls = urls
            }
        }
    }
    
    // Select an audio file from the picker and assign the URL to `audioFile`
    func selectAudioFile() {
        MediaPicker.pickAudioFile { audioUrl in
            guard let selectedAudio = audioUrl else { return }
            do {
                let player = try AVAudioPlayer(contentsOf: selectedAudio)
                DispatchQueue.main.async {
                    self.audioPlayer = player
                    self.audioPlayer?.numberOfLoops = -1 // Loop
                    self.audioPlayer?.prepareToPlay()
                }
            } catch {
                print("Failed to initialize audio player: ", error)
            }
        }
    }
    
    // True if some numbers of videos are picked AND some number of screens have been picked for the videos.
    func videosReadyForPlayback() -> Bool {
      guard !videoUrls.isEmpty else { return false }
      guard selectedScreenForVideos.contains(where: { $0 != nil }) else { return false }
      return true
    }

    
    func updatePlayers() {
        previewVideoPlayers = videoUrls.map { AVPlayer(url: $0) }
        externalScreenVideoPlayers = videoUrls.map { AVPlayer(url: $0) }
        selectedScreenForVideos = Array(repeating: nil, count: videoUrls.count) // Reset selections when the videos change
    }
    
    func resetSelections() {
        selectedScreenForVideos = Array(repeating: nil, count: videoUrls.count) // Reset selections when the screens change
    }
    
    func startPlayback() {
        areVideosPlaying = true
        launchSplitVideo()
    }
    
    // The strategy is to iterate over all available screens, detect which videos are set to play on them and broadcast them accordingly.
    private func launchSplitVideo() {
        screenWindows.forEach { $0.close() }
        screenWindows.removeAll()
        
        // Play audio
        audioPlayer?.play()
        
        // Iterate over screens.
        for (screenIndex, screen) in model.screens.enumerated() {
            // Isolate videos intended for this screen
            var videosForScreen: [Int] = []
            // videoIndex is the indice of the array; e.g. if it's 0 then it's the first video of the selection and we're checking the screen it's assigned to -- if the value it's assigned to is 1 then we're assigning it to the second screen available.
            for (videoIndex, screenSelection) in selectedScreenForVideos.enumerated() {
                // If the screen we're currently looking at is the one assigned to the video currently being analysed
                if (screenIndex == screenSelection) {
                    videosForScreen.append(videoIndex)
                }
            }
            
            // If no videos are assigned to this screen, return early
            if (videosForScreen.isEmpty) { continue }
            
            // Create the frames for the screen based on the screen dimensions
            let fullFrame = screen.frame
            let subframeWidth = fullFrame.width / CGFloat(videosForScreen.count)
            let splitView = NSView(frame: fullFrame) // View where we'll piece 2 players views together to one NSView
            splitView.wantsLayer = true
            splitView.layer?.masksToBounds = true  // clip subviews
            
            let correspondingVideoPlayers = videosForScreen.map{ videoIndex in
                externalScreenVideoPlayers[videoIndex]
            }
            
            // Construct player views for each video player and draw on splitView (the intermediary view)
            for (index, player) in correspondingVideoPlayers.enumerated() {
                let xOrigin = CGFloat(index) * subframeWidth
                let subFrame = NSRect(x: xOrigin, y: 0, width: subframeWidth, height: fullFrame.height)
                
                let playerView = AVPlayerView(frame: subFrame)
                playerView.player = player
                playerView.controlsStyle = .none // Hide controls
                playerView.videoGravity = .resizeAspectFill  // fill & crop
                playerView.wantsLayer = true
                playerView.layer?.masksToBounds = true
                
                playerView.player?.seek(to: .zero) // Play the videos from the start
                playerView.player?.play() // Start the video immediately
                
                splitView.addSubview(playerView)
            }
            
            // Make a brand-new window on that screen
            let window = NSWindow(
                contentRect: fullFrame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            
            // Set window settings
            window.setFrame(screen.frame, display: true) // Center on screen and size to fill
            window.level = .screenSaver // Full screen
            window.contentView = splitView // Place view into the screen
            window.makeKeyAndOrderFront(nil) // Bring to front
            window.isReleasedWhenClosed = false // Do not immediately deallocate the window object as soon as it’s closed -- gives us full control over its lifeitme
            
            screenWindows.append(window)
        }
    }
    
    func stopPlayback() {
        // Stop and reset audio
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        
        // Remove all windows on screens
        screenWindows.forEach { $0.close() }
        screenWindows.removeAll()
        
        areVideosPlaying = false
    }
}
