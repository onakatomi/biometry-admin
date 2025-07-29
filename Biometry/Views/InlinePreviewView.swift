//
//  InlinePreviewView.swift
//  Biometry
//
//  Created by Nakatomi on 17/7/2025.
//

// In-line preview of selected videos.

import SwiftUI
import AVKit

struct InlinePreviewView: View {
    let players: [AVPlayer]
    let screens: [NSScreen]
    @Binding var selectedScreenForVideos: [Int?]
    
    var body: some View {
        if players.isEmpty {
            Text("Pick some videos to preview...")
        } else {
            HStack {
                ForEach(players.indices, id: \.self) { i in
                    VStack(spacing: 8) {
                        Text("Video \(i+1):")
                        
                        // In-line preview player
                        VideoPlayer(player: players[i])
                            .aspectRatio(16.0/9.0, contentMode: .fill)
                            .frame(width: 240, height: 135)
                            .clipped()
                            .onAppear { players[i].play() }
                        
                        // Dropdown screen picker
                        Picker("Screen", selection: $selectedScreenForVideos[i]) {
                            Text("None selected").tag(nil as Int?)
                            ForEach(0..<screens.count, id: \.self) { screen in
                                Text("Screen \(screen+1)").tag(Optional(screen))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: 200)
                    }
                }
            }
        }
    }
}
