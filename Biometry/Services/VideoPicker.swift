//
//  VideoPicker.swift
//  Biometry
//
//  Created by Nakatomi on 17/7/2025.
//

import AppKit
import UniformTypeIdentifiers

// Open the native file picker to select videos to playback
struct VideoPicker {
    static func pickVideos(completion: @escaping ([URL]) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .video]
        panel.allowsMultipleSelection = true
        panel.begin { response in
            guard response == .OK else { return }
            completion(panel.urls)
        }
    }
}
