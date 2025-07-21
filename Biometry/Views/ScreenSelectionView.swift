//
//  ScreenSelectionView.swift
//  Biometry
//
//  Created by Nakatomi on 17/7/2025.
//

import SwiftUI
import CoreGraphics

struct ScreenSelectionView: View {
    let screens: [NSScreen]
    let cgDisplayIDs: [CGDirectDisplayID]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Available screens for playback:")
                .font(.headline)
            ForEach(screens.indices, id: \.self) { i in
                HStack(spacing: 16) {
                    let displayID = cgDisplayIDs[i]
                    let mode = CGDisplayCopyDisplayMode(displayID)
                    Text("Screen \(i+1): \(mode?.pixelWidth ?? 0)x\(mode?.pixelHeight ?? 0)")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top)
    }
}
