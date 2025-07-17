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
    
    var body: some View {
        if players.isEmpty {
            Text("Pick some videos to preview...")
        } else {
            HStack {
                ForEach(players.indices, id: \.self) { i in
                    VideoPlayer(player: players[i])
                        .frame(height: 100)
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .onAppear { players[i].play() }
                }
            }
        }
    }
}
