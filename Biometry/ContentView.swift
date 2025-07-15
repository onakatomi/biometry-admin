//
//  ContentView.swift
//  Biometry
//
//  Created by Nakatomi on 15/7/2025.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @State private var videoUrl: URL?
    @State private var player = AVPlayer()
    @StateObject private var model = DisplayModel()
    
    var body: some View {
        ZStack {
            // Background colour
            Color(.darkGray)
                .ignoresSafeArea()
            
            // Column
            VStack(spacing: 16){
                Image(systemName: "toilet")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Welcome to Biometry!")
                    .bold()
                    .font(.title)
                
                if let _ = videoUrl {
                    // Inline preview of selected video
                    VideoPlayer(player: player)
                        .frame(height: 100)
                        .aspectRatio(contentMode: .fit)
                        .fixedSize(horizontal: true, vertical: false)
                        .onAppear { player.play() }
                        .onChange(of: videoUrl) { _, newURL in
                            guard let u = newURL else { return }
                            player.replaceCurrentItem(with: .init(url: u))
                            player.play()
                        }
                    
                    // Now the list of screens + “Play Here” buttons
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose a screen to play on:")
                            .font(.headline)
                        
                        ForEach(model.screens.indices, id: \.self) { i in
                            HStack {
                                let screen = model.screens[i]
                                Text("Screen \(i+1): \(Int(screen.frame.width))×\(Int(screen.frame.height))")
                                Spacer()
                                Button("Play Here") {
                                    playOnScreen(screen)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(.top)
                } else {
                    Text("No files currently selected.")
                }
                
                // Select files button
                PrimaryButton(text: "Choose files") {
                    selectVideo()
                }
                
            }
            .padding()
        }
    }
    
    func selectVideo() {
        let openPanel = NSOpenPanel() // Let user browse for files
        
        // Only allow video types to be selected
        if #available(macOS 12.0, *) {
            openPanel.allowedContentTypes = [.video, .movie]
            
        } else {
            openPanel.allowedFileTypes = ["mp4", "mov", "m4v"]
        }
        
        openPanel.allowsMultipleSelection = false
        
        // `begin` shows the panel without blocking the app’s main thread -- non-blocking
        // Closure is passed one value (result) and returns nothing.
        openPanel.begin { (result) -> Void in
            // We compare the result's .rawValue to .OK.rawValue to see if the user hit “Open” (as opposed to “Cancel”). This closure is called (with the result returned) when the panels exits.
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                videoUrl = openPanel.url // set state to the video URL
            }
        }
    }
    
    private func playOnScreen(_ screen: NSScreen) {
        guard let url = videoUrl else { return }
        
        // Make a brand-new window on that screen
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        
        // Center on screen and size to fill
        window.setFrame(screen.frame, display: true)
        
        // Create an AVPlayerView to fit video and play it
        let avView = AVPlayerView(frame: screen.frame)
        avView.player = AVPlayer(url: url)
        avView.player?.play()
        avView.videoGravity = .resizeAspect  // or .resizeAspectFill to crop
        
        // Place the AV View into the screen
        window.contentView = avView
        
        // Bring to front and play fullscreen.
        window.makeKeyAndOrderFront(nil)
        window.toggleFullScreen(nil)
    }
}

#Preview {
    ContentView()
}
