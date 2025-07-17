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
    @Binding var selectedVideoForScreen: [Int?]
    let videoCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Available screens:")
                .font(.headline)
            ForEach(screens.indices, id: \.self) { i in
                HStack(spacing: 16) {
                    let displayID = cgDisplayIDs[i]
                    let mode = CGDisplayCopyDisplayMode(displayID)
                    Text("Screen \(i+1): \(mode?.pixelWidth ?? 0)x\(mode?.pixelHeight ?? 0)")
                    
                    if (selectedVideoForScreen.indices.contains(i)) {
                        Picker("Video", selection: $selectedVideoForScreen[i]) {
                            Text("None").tag(nil as Int?)
                            ForEach(0..<videoCount, id: \.self) { vid in
                                Text("Video \(vid+1)").tag(Optional(vid))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: 120)
                    }
                    
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top)
    }
}
